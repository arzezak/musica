# frozen_string_literal: true

require "yaml"
require "fileutils"

module Musica
  class Cli
    def initialize(argv)
      @prompt = argv.join(" ")
      @player = Musica::Player.new(application: load_config)
    end

    def run
      player.tell prompt unless prompt.empty?
      $stdout << "\u{1F3A7} #{player.status}\n"
    end

    private

    attr_reader :argv, :player, :prompt

    def load_config
      config_dir = "#{ENV["XDG_CONFIG_HOME"]}/musica" || File.expand_path("~/.config/musica")
      config_file = File.join(config_dir, "config.yml")

      unless File.exist?(config_file)
        create_config(config_dir, config_file)
      end

      YAML.load_file(config_file).dig("player")
    end

    def create_config(config_dir, config_file)
      FileUtils.mkdir_p(config_dir)

      default_config = { "player" => "Music" }

      File.write(config_file, YAML.dump(default_config))
    end
  end
end
