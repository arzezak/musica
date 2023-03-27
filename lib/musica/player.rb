# frozen_string_literal: true

module Musica
  class Player
    def initialize(application:)
      @application = application
    end

    def status
      (state == "playing") ? track : state
    end

    def track
      "#{artist} - #{name}"
    end

    private

    attr_reader :application

    def artist
      tell "return artist of the current track"
    end

    def name
      tell "return name of the current track"
    end

    def state
      tell "return player state"
    end

    def tell(command)
      `osascript -e 'tell application "#{application}" to #{command}'`.chomp
    end
  end
end
