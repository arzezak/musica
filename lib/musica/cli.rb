# frozen_string_literal: true

module Musica
  class Cli
    HELP = <<~TEXT
      Usage: musica [request]
             musica -s <applescript>

      Without arguments, print what's playing. With a request, turn it into a
      command using fm, send it to the music player, then print what's playing.

      Options:
        -s, --script   Send an AppleScript command to the player as is
        -h, --help     Show this help
        -v, --version  Show the version

      Examples:
        musica skip this song
        musica play the album Adore
        musica -s set sound volume to 50

      The player is set in musica/config.yml, under $XDG_CONFIG_HOME or ~/.config.
    TEXT

    def initialize(argv, player: nil, interpreter: nil, out: $stdout)
      @argv = argv
      @player = player
      @interpreter = interpreter
      @out = out
    end

    def run
      case argv.first
      when "-h", "--help"
        out << HELP
      when "-v", "--version"
        out << "musica #{VERSION}\n"
      when "-s", "--script"
        play argv.drop(1).join(" ")
      else
        play(argv.empty? ? "" : interpreter.call(argv.join(" ")))
      end
    end

    private

    attr_reader :argv, :out

    def play(command)
      player.tell command unless command.empty?
      out << "\u{1F3A7} #{player.status}\n"
    end

    def player
      @player ||= Player.new(application: Config.player)
    end

    def interpreter
      @interpreter ||= Interpreter.new
    end
  end
end
