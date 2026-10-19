# Musica

This is a Ruby command-line tool that interacts with music players on macOS
using AppleScript.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add musica

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install musica

## Usage

Musica passes its arguments straight to your music player as an AppleScript
command, so `musica <command>` runs:

```applescript
tell application "<player>" to <command>
```

Any command in the player's AppleScript dictionary works (open it in Script
Editor with File > Open Dictionary). For example:

    $ musica play
    $ musica pause
    $ musica playpause
    $ musica next track
    $ musica previous track
    $ musica set sound volume to 50

After each command, Musica prints the current status: the artist and track
while playing, otherwise the player state:

    $ musica play
    🎧 Daft Punk - Digital Love
    $ musica pause
    🎧 paused

Run `musica` without arguments to print the status alone.

Commands can differ between players. For example, Music uses
`set shuffle enabled to true` and Spotify uses `set shuffling to true`. Wrap
commands that contain quotes in single quotes so the shell keeps them:

    $ musica 'play playlist "Favorite Songs"'

## Configuration

Musica can be configured to work with different music players. Create a configuration file at:
- `$XDG_CONFIG_HOME/musica/config.yml` (if XDG_CONFIG_HOME is set)
- `~/.config/musica/config.yml` (default)

Example configuration:
```yaml
player: "Spotify"
```

If no configuration file exists, one will be created automatically with the default player set to "Music".

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/arzezak/musica. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/arzezak/musica/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Musica project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/arzezak/musica/blob/main/CODE_OF_CONDUCT.md).
