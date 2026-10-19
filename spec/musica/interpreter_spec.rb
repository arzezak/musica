# frozen_string_literal: true

RSpec.describe Musica::Interpreter do
  let(:intent) { {} }
  let(:interpreter) { described_class.new(runner: ->(_request) { JSON.generate(intent) }) }

  describe "#call" do
    {
      "play" => "play",
      "pause" => "pause",
      "next_track" => "next track",
      "previous_track" => "previous track"
    }.each do |action, command|
      it "turns #{action} into #{command}" do
        intent["action"] = action

        expect(interpreter.call("do it")).to eq(command)
      end
    end

    it "changes the volume by the delta" do
      intent.merge!("action" => "change_volume", "delta" => -10)

      expect(interpreter.call("quieter")).to eq("set sound volume to (sound volume + -10)")
    end

    it "plays a track by name and artist" do
      intent.merge!("action" => "play_track", "name" => "Black Dog", "artist" => "Led Zeppelin")

      expect(interpreter.call("play black dog by led zeppelin")).to eq(
        %(play (some track of library playlist 1 whose name is "Black Dog" and artist is "Led Zeppelin"))
      )
    end

    it "plays a track by artist when the action is play" do
      intent.merge!("action" => "play", "artist" => "Queen")

      expect(interpreter.call("play something by Queen")).to eq(
        %(play (some track of library playlist 1 whose artist is "Queen"))
      )
    end

    it "plays an album through the Musica playlist" do
      intent.merge!("action" => "play_album", "album" => "Adore", "artist" => "The Smashing Pumpkins")

      script = interpreter.call("play the album adore by the smashing pumpkins")

      expect(script).to start_with(
        %(set found to every track of library playlist 1 whose album is "Adore" and artist is "The Smashing Pumpkins"\n)
      )
      expect(script).to include(%(error "No album " & "Adore" & " in your library"))
      expect(script).to end_with("play musica\n")
    end

    it "plays a track from an album" do
      intent.merge!("action" => "play_track", "name" => "Ava Adore", "album" => "Adore")

      expect(interpreter.call("play Ava Adore from Adore")).to eq(
        %(play (some track of library playlist 1 whose name is "Ava Adore" and album is "Adore"))
      )
    end

    it "ignores an artist the request doesn't mention" do
      intent.merge!("action" => "play_track", "name" => "Black Dog", "artist" => "U2")

      expect(interpreter.call("put on Black Dog")).to eq(
        %(play (some track of library playlist 1 whose name is "Black Dog"))
      )
    end

    it "ignores a name on other actions" do
      intent.merge!("action" => "next_track", "name" => "unknown")

      expect(interpreter.call("skip this unknown song")).to eq("next track")
    end

    it "escapes quotes and backslashes in names" do
      intent.merge!("action" => "play_track", "name" => %(Say "Hi" \\o/))

      expect(interpreter.call(%(play Say "Hi" \\o/))).to eq(
        %(play (some track of library playlist 1 whose name is "Say \\"Hi\\" \\\\o/"))
      )
    end

    it "raises for requests it doesn't understand" do
      intent["action"] = "unknown"

      expect { interpreter.call("what's the weather") }
        .to raise_error(Musica::Error, %(Couldn't understand "what's the weather"))
    end

    it "raises for a volume change without a delta" do
      intent["action"] = "change_volume"

      expect { interpreter.call("volume") }.to raise_error(Musica::Error)
    end
  end

  describe "FM" do
    it "asks fm for an intent matching the schema" do
      allow(Open3).to receive(:capture2).and_return([%({"action": "play"}), instance_double(Process::Status, success?: true)])

      expect(described_class::FM.call("resume")).to eq(%({"action": "play"}))
      expect(Open3).to have_received(:capture2).with(
        "fm", "respond", "--no-stream", "--greedy",
        "--schema", described_class::SCHEMA, "--instructions", described_class::INSTRUCTIONS, "resume"
      )
    end

    it "raises when fm isn't installed" do
      allow(Open3).to receive(:capture2).and_raise(Errno::ENOENT)

      expect { described_class::FM.call("resume") }.to raise_error(Musica::Error, /Requests need fm/)
    end
  end
end
