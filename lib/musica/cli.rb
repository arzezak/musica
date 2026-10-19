# frozen_string_literal: true

module Musica
  class Cli
    def initialize(argv)
      @prompt = argv.join(" ")
      @player = Musica::Player.new(application: Musica::Config.player)
    end

    def run
      player.tell prompt unless prompt.empty?
      $stdout << "\u{1F3A7} #{player.status}\n"
    end

    private

    attr_reader :player, :prompt
  end
end
