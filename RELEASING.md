# Releasing

1. Pick the next version. Check that it isn't on RubyGems yet with
   `gem list -r '^musica$'`. A published version can't be replaced, so a
   version that is already there needs a new number.
2. Update `VERSION` in `lib/musica/version.rb`, then run `bundle install` so
   `Gemfile.lock` picks it up.
3. Add an entry at the top of `CHANGELOG.md` with the version, the date, and
   what changed since the last release.
4. Run `bundle exec rake` to run the specs and the linter.
5. Commit, push `main`, and wait for CI to pass on both Ruby versions.
6. Run `bundle exec rake release`. It builds the gem, tags `vX.Y.Z`, pushes the
   tag, and publishes the gem to rubygems.org. RubyGems asks for your OTP code,
   so run it in a terminal where you can type it. In Claude Code, that's
   `! bundle exec rake release`.
7. Check that the new version is listed by `gem list -r '^musica$'`.
