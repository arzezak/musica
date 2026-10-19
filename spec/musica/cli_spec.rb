# frozen_string_literal: true

require "stringio"

RSpec.describe Musica::Cli do
  let(:player) { instance_double(Musica::Player, tell: "", status: "Led Zeppelin - Black Dog") }
  let(:interpreter) { instance_double(Musica::Interpreter, call: "next track") }
  let(:out) { StringIO.new }

  describe "#run" do
    context "without arguments" do
      it "prints the status without telling the player anything" do
        run

        expect(interpreter).not_to have_received(:call)
        expect(player).not_to have_received(:tell)
        expect(out.string).to eq("\u{1F3A7} Led Zeppelin - Black Dog\n")
      end
    end

    context "with a request" do
      it "tells the player the interpreted request, then prints the status" do
        run(*%w[skip this song])

        expect(interpreter).to have_received(:call).with("skip this song")
        expect(player).to have_received(:tell).with("next track")
        expect(out.string).to eq("\u{1F3A7} Led Zeppelin - Black Dog\n")
      end
    end

    %w[-s --script].each do |flag|
      context "with #{flag}" do
        it "tells the player the joined arguments as is, then prints the status" do
          run(flag, *%w[set sound volume to 50])

          expect(interpreter).not_to have_received(:call)
          expect(player).to have_received(:tell).with("set sound volume to 50")
          expect(out.string).to eq("\u{1F3A7} Led Zeppelin - Black Dog\n")
        end
      end
    end

    {
      "-h" => described_class::HELP,
      "--help" => described_class::HELP,
      "-v" => "musica #{Musica::VERSION}\n",
      "--version" => "musica #{Musica::VERSION}\n"
    }.each do |flag, output|
      context "with #{flag}" do
        it "prints its output without talking to the player" do
          run(flag)

          expect(player).not_to have_received(:tell)
          expect(player).not_to have_received(:status)
          expect(out.string).to eq(output)
        end
      end
    end
  end

  private

  def run(*argv)
    described_class.new(argv, player: player, interpreter: interpreter, out: out).run
  end
end
