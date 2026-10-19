# Musica

This is a Ruby command-line tool that interacts with music players on macOS
using AppleScript.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add musica

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install musica

## Usage

Tell Musica what you want in plain words:

    $ musica skip this song
    $ musica turn it down a bit
    $ musica play Digital Love by Daft Punk
    $ musica play something by Queen
    $ musica play the album Adore

Musica uses Apple's on-device model, through the `fm` command, to turn the
request into a command for your music player. This needs macOS 26 with Apple
Intelligence. The exact commands `play`, `pause`, `next track` and
`previous track` go straight to the player, without `fm`.

It understands play, pause, next and previous track, volume changes, and
playing a track or album from your library by name, artist or album. To play
an album in order, Musica fills a playlist named "Musica" with its tracks and
plays that playlist, replacing what was in it before. Playing from your library
only works with Music.

After each request, Musica prints the current status: the artist and track
while playing, otherwise the player state:

    $ musica play
    🎧 Daft Punk - Digital Love
    $ musica pause
    🎧 paused

Run `musica` without arguments to print the status alone, `musica --help` for
a summary of the options, and `musica --version` for the version.

### AppleScript

With `-s` (or `--script`), Musica sends its arguments to the player as an
AppleScript command, without `fm`. Any command in the player's AppleScript
dictionary works (open it in Script Editor with File > Open Dictionary):

    $ musica -s playpause
    $ musica -s set sound volume to 50

Commands can differ between players. For example, Music uses
`set shuffle enabled to true` and Spotify uses `set shuffling to true`. Wrap
commands that contain quotes in single quotes so the shell keeps them:

    $ musica -s 'play playlist "Favorite Songs"'

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
release a new version, follow [RELEASING.md](RELEASING.md).

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
