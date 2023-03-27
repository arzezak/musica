# frozen_string_literal: true

RSpec.describe Musica::Player do
  let(:player) { described_class.new(application: "Music") }

  describe "#status" do
    context "when not running" do
      it "returns stopped" do
        mock("return player state").and_return("stopped\n")

        expect(player.status).to eq("stopped")
      end
    end

    context "when running" do
      context "when no track is playing" do
        it "returns stopped" do
          mock("return player state").and_return("stopped\n")

          expect(player.status).to eq("stopped")
        end
      end

      context "when the player is paused" do
        it "returns paused" do
          mock("return player state").and_return("paused\n")

          expect(player.status).to eq("paused")
        end
      end

      context "when playing" do
        it "returns the name and the artist of the current track" do
          mock("return player state").and_return("playing\n")
          mock("return artist of the current track").and_return("Led Zeppelin")
          mock("return name of the current track").and_return("Black Dog")

          expect(player.status).to eq("Led Zeppelin - Black Dog")
        end
      end
    end
  end

  private

  def mock(command)
    allow_any_instance_of(Kernel).to receive(:`)
      .with("osascript -e 'tell application \"Music\" to #{command}'")
  end
end
