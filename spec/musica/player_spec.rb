# frozen_string_literal: true

RSpec.describe Musica::Player do
  let(:responses) { {} }
  let(:runner) { ->(script) { responses.fetch(script) } }
  let(:player) { described_class.new(application: "Music", runner: runner) }

  describe "#status" do
    context "when stopped" do
      it "returns stopped" do
        respond("return player state", "stopped")

        expect(player.status).to eq("stopped")
      end
    end

    context "when paused" do
      it "returns paused" do
        respond("return player state", "paused")

        expect(player.status).to eq("paused")
      end
    end

    context "when playing" do
      it "returns the artist and the name of the current track" do
        respond("return player state", "playing")
        respond("return artist of the current track", "Led Zeppelin")
        respond("return name of the current track", "Black Dog")

        expect(player.status).to eq("Led Zeppelin - Black Dog")
      end
    end
  end

  describe "#tell" do
    it "sends the command to the application" do
      respond("play", "")

      expect(player.tell("play")).to eq("")
    end
  end

  describe "OSASCRIPT" do
    it "passes the script as a single argument, without a shell" do
      allow(Open3).to receive(:capture2).and_return(["out\n", nil])

      result = described_class::OSASCRIPT.call(%(play track "Don't Stop"))

      expect(Open3).to have_received(:capture2).with("osascript", "-e", %(play track "Don't Stop"))
      expect(result).to eq("out")
    end
  end

  private

  def respond(command, output)
    responses[%(tell application "Music" to #{command})] = output
  end
end
