# frozen_string_literal: true

module Musica
  class Cli
    def initialize(argv, player: Player.new(application: Config.player), interpreter: Interpreter.new, out: $stdout)
      @natural = argv.first == "-n"
      @prompt = argv.drop(@natural ? 1 : 0).join(" ")
      @player = player
      @interpreter = interpreter
      @out = out
    end

    def run
      player.tell command unless prompt.empty?
      out << "\u{1F3A7} #{player.status}\n"
    end

    private

    attr_reader :interpreter, :natural, :out, :player, :prompt

    def command
      natural ? interpreter.call(prompt) : prompt
    end
  end
end
