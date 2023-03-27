module Musica
  class Cli
    def initialize(argv)
      @prompt = argv.join(" ")
      @player = Musica::Player.new(application: "Music")
    end

    def run
      player.tell prompt unless prompt.empty?
      $stdout << "\u{1F3A7} #{player.status}\n"
    end

    private

    attr_reader :argv, :player, :prompt
  end
end
