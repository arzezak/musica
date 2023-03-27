module Musica
  class Cli
    def initialize(argv)
      @argv = argv
    end

    def run
      puts Musica::Player.new(application: "Music").status
    end
  end
end
