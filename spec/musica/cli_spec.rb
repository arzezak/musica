# frozen_string_literal: true

require "stringio"

RSpec.describe Musica::Cli do
  let(:player) { instance_double(Musica::Player, tell: "", status: "Led Zeppelin - Black Dog") }
  let(:out) { StringIO.new }

  describe "#run" do
    context "without arguments" do
      it "prints the status without telling the player anything" do
        described_class.new([], player: player, out: out).run

        expect(player).not_to have_received(:tell)
        expect(out.string).to eq("\u{1F3A7} Led Zeppelin - Black Dog\n")
      end
    end

    context "with arguments" do
      it "tells the player the joined arguments, then prints the status" do
        described_class.new(%w[next track], player: player, out: out).run

        expect(player).to have_received(:tell).with("next track")
        expect(out.string).to eq("\u{1F3A7} Led Zeppelin - Black Dog\n")
      end
    end

    context "with -n" do
      let(:interpreter) { instance_double(Musica::Interpreter, call: "next track") }

      it "tells the player the interpreted request, then prints the status" do
        described_class.new(%w[-n skip this song], player: player, interpreter: interpreter, out: out).run

        expect(interpreter).to have_received(:call).with("skip this song")
        expect(player).to have_received(:tell).with("next track")
        expect(out.string).to eq("\u{1F3A7} Led Zeppelin - Black Dog\n")
      end
    end
  end
end
