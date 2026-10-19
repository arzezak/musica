# frozen_string_literal: true

module Musica
  class Cli
    def initialize(argv, player: Player.new(application: Config.player), out: $stdout)
      @prompt = argv.join(" ")
      @player = player
      @out = out
    end

    def run
      player.tell prompt unless prompt.empty?
      out << "\u{1F3A7} #{player.status}\n"
    end

    private

    attr_reader :out, :player, :prompt
  end
end
