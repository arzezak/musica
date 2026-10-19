# frozen_string_literal: true

require "tmpdir"

RSpec.describe Musica::Config do
  around do |example|
    Dir.mktmpdir { |dir| @dir = dir and example.run }
  end

  describe ".player" do
    context "when XDG_CONFIG_HOME is set" do
      let(:env) { {"XDG_CONFIG_HOME" => @dir, "HOME" => "/nonexistent"} }

      it "reads the config from XDG_CONFIG_HOME" do
        write_config("#{@dir}/musica/config.yml", "player" => "Spotify")

        expect(described_class.player(env: env)).to eq("Spotify")
      end
    end

    context "when XDG_CONFIG_HOME is not set" do
      let(:env) { {"HOME" => @dir} }

      it "reads the config from ~/.config" do
        write_config("#{@dir}/.config/musica/config.yml", "player" => "Spotify")

        expect(described_class.player(env: env)).to eq("Spotify")
      end
    end

    context "when XDG_CONFIG_HOME is empty" do
      let(:env) { {"XDG_CONFIG_HOME" => "", "HOME" => @dir} }

      it "falls back to ~/.config" do
        write_config("#{@dir}/.config/musica/config.yml", "player" => "Spotify")

        expect(described_class.player(env: env)).to eq("Spotify")
      end
    end

    context "when no config file exists" do
      let(:env) { {"HOME" => @dir} }

      it "returns the default player" do
        expect(described_class.player(env: env)).to eq("Music")
      end

      it "creates the config file with the default player" do
        described_class.player(env: env)

        expect(YAML.load_file("#{@dir}/.config/musica/config.yml")).to eq("player" => "Music")
      end
    end

    context "when the config file has no player" do
      let(:env) { {"HOME" => @dir} }

      it "returns the default player" do
        write_config("#{@dir}/.config/musica/config.yml", {})

        expect(described_class.player(env: env)).to eq("Music")
      end
    end
  end

  private

  def write_config(file, config)
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, YAML.dump(config))
  end
end
