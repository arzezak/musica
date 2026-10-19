# frozen_string_literal: true

require "json"
require "open3"

module Musica
  class Interpreter
    SCHEMA = File.expand_path("intent.json", __dir__)

    INSTRUCTIONS = <<~TEXT
      You turn a request to a music player into an action.
      - play: resume playback
      - pause: pause or stop playback
      - next_track: skip to the next song ("next", "skip")
      - previous_track: go back to the previous song
      - change_volume: louder or quieter; delta is the change, 10 for a bit, 30 for a lot, negative for quieter
      - play_track: play a specific song; name is the song title, artist only if the request names one
      - unknown: anything else
    TEXT

    FM = lambda do |request|
      output, status = Open3.capture2(
        "fm", "respond", "--no-stream", "--greedy",
        "--schema", SCHEMA, "--instructions", INSTRUCTIONS, request
      )
      raise Error, "fm failed to interpret \"#{request}\"" unless status.success?

      output
    rescue Errno::ENOENT
      raise Error, "Natural language commands need fm (macOS 26 with Apple Intelligence)"
    end

    COMMANDS = {
      "play" => "play",
      "pause" => "pause",
      "next_track" => "next track",
      "previous_track" => "previous track"
    }.freeze

    def initialize(runner: FM)
      @runner = runner
    end

    def call(request)
      intent = JSON.parse(runner.call(request))
      # The model sometimes invents a name or artist, so keep only what the request mentions
      name = mentioned(intent["name"], request)
      artist = mentioned(intent["artist"], request)

      case intent["action"]
      when "play", "play_track"
        (name || artist) ? play(name, artist) : "play"
      when "change_volume"
        volume(intent["delta"], request)
      else
        COMMANDS.fetch(intent["action"]) { not_understood(request) }
      end
    end

    private

    attr_reader :runner

    def mentioned(value, request)
      value if value.is_a?(String) && !value.empty? && request.downcase.include?(value.downcase)
    end

    def play(name, artist)
      filters = {"name" => name, "artist" => artist}.compact.map { |key, value| "#{key} is #{quote(value)}" }

      "play (some track of library playlist 1 whose #{filters.join(" and ")})"
    end

    def volume(delta, request)
      not_understood(request) unless delta.is_a?(Integer)

      "set sound volume to (sound volume + #{delta})"
    end

    def quote(value)
      %("#{value.gsub(/[\\"]/) { |char| "\\#{char}" }}")
    end

    def not_understood(request)
      raise Error, "Couldn't understand \"#{request}\""
    end
  end
end
