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
      - play_album: play an album; album is the album title, artist only if the request names one
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
      raise Error, "Requests need fm (macOS 26 with Apple Intelligence); use -s to send AppleScript instead"
    end

    COMMANDS = {
      "play" => "play",
      "pause" => "pause",
      "next_track" => "next track",
      "previous_track" => "previous track"
    }.freeze

    # Music can't play an album or queue tracks, so refill a playlist with the
    # album in disc and track order and play that instead
    ALBUM = <<~APPLESCRIPT
      set found to every track of library playlist 1 whose %<conditions>s
      if found is {} then error "No album " & %<album>s & " in your library"
      set positions to {}
      repeat with t in found
        set end of positions to (disc number of t) * 1000 + (track number of t)
      end repeat
      if not (exists user playlist "Musica") then make new user playlist with properties {name:"Musica"}
      set musica to user playlist "Musica"
      delete every track of musica
      repeat (count of found) times
        set best to 0
        repeat with i from 1 to count of found
          if item i of positions is not missing value then
            if best is 0 or item i of positions < item best of positions then set best to i
          end if
        end repeat
        duplicate item best of found to musica
        set item best of positions to missing value
      end repeat
      play musica
    APPLESCRIPT

    def initialize(runner: FM)
      @runner = runner
    end

    def call(request)
      intent = JSON.parse(runner.call(request))
      name = mentioned(intent["name"], request)
      artist = mentioned(intent["artist"], request)
      album = mentioned(intent["album"], request)

      case intent["action"]
      when "play", "play_track", "play_album"
        if album && !name
          play_album(album, artist)
        elsif name || artist
          play_track(name, artist, album)
        else
          "play"
        end
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

    def play_track(name, artist, album)
      "play (some track of library playlist 1 whose #{conditions("name" => name, "artist" => artist, "album" => album)})"
    end

    def play_album(album, artist)
      format(ALBUM, conditions: conditions("album" => album, "artist" => artist), album: quote(album))
    end

    def conditions(filters)
      filters.compact.map { |key, value| "#{key} is #{quote(value)}" }.join(" and ")
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
