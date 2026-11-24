# Camunda Homebrew tap

```sh
brew install camunda/tap/d8ctl   # One CLI for every Camunda API, built for agents
brew install camunda/tap/c8ctl   # The Camunda 8 CLI (installs `c8ctl` and `c8`)
```

`brew upgrade` picks up new releases. The tap follows upstream within about an
hour.

| Formula | Upstream | Installs |
| --- | --- | --- |
| [`d8ctl`](Formula/d8ctl.rb) | [camunda/d8ctl](https://github.com/camunda/d8ctl) GitHub Releases | The prebuilt native binary for macOS (arm64, Intel) or Linux (x64, arm64). No dependencies. |
| [`c8ctl`](Formula/c8ctl.rb) | [`@camunda8/cli`](https://www.npmjs.com/package/@camunda8/cli) on npm ([camunda/c8ctl](https://github.com/camunda/c8ctl)) | The npm package, with Homebrew's `node`. c8ctl plugins install into c8ctl's data folder, not into the Homebrew prefix, so they survive upgrades. |

## How it stays current

[`update.yml`](.github/workflows/update.yml) runs hourly. It runs
[`.github/scripts/update.py`](.github/scripts/update.py) to read the newest
camunda/d8ctl release (taking checksums from its `.sha256` files and checking
them against the binaries) and the `latest` version of `@camunda8/cli`. It
installs and tests any formula that changed, then commits it to `main`. You can
also run it by hand: `gh workflow run update -R camunda/homebrew-tap`.

[`tests.yml`](.github/workflows/tests.yml) runs `brew style`, `brew audit
--strict`, install and `brew test` for every formula on macOS (arm64, Intel)
and Linux (x64, arm64).

## Adding a formula

Add `Formula/<name>.rb` with a `test do` block that runs the installed
command, add the formula to the matrix in `tests.yml`, and, if it should
update itself, add a function for it to `update.py`.
