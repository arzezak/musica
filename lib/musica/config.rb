# frozen_string_literal: true

require "yaml"
require "fileutils"

module Musica
  module Config
    DEFAULTS = {"player" => "Music"}.freeze

    def self.player(env: ENV)
      file = path(env)

      unless File.exist?(file)
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, YAML.dump(DEFAULTS))
      end

      (YAML.load_file(file) || {}).fetch("player", DEFAULTS["player"])
    end

    def self.path(env)
      base = env["XDG_CONFIG_HOME"]
      base = File.join(env.fetch("HOME"), ".config") if base.nil? || base.empty?

      File.join(base, "musica", "config.yml")
    end
    private_class_method :path
  end
end
