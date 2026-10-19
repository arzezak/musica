# frozen_string_literal: true

require "open3"

module Musica
  class Player
    OSASCRIPT = ->(script) { Open3.capture2("osascript", "-e", script).first.chomp }

    def initialize(application:, runner: OSASCRIPT)
      @application = application
      @runner = runner
    end

    def status
      (state == "playing") ? track : state
    end

    def tell(command)
      runner.call(%(tell application "#{application}" to #{command}))
    end

    private

    attr_reader :application, :runner

    def artist
      tell "return artist of the current track"
    end

    def name
      tell "return name of the current track"
    end

    def state
      tell "return player state"
    end

    def track
      "#{artist} - #{name}"
    end
  end
end
