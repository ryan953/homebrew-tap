# homebrew-tap

A personal Homebrew tap for software by [@ryan953](https://github.com/ryan953).

## Install

```sh
brew tap ryan953/tap
brew install ryan953/tap/repo-metrics
brew install --cask ryan953/tap/dex-ui
```

Homebrew 6 trusts a third-party formula the first time you install it by its
full name. To trust the whole tap once, and everything added to it later:

```sh
brew trust --tap ryan953/tap
```

After that you can use short names:

```sh
brew install repo-metrics
brew upgrade repo-metrics
```

## What is in the tap

Formulae are command-line programs. Casks are macOS applications.

| Formula | Source | Description |
| --- | --- | --- |
| `repo-metrics` | [getsentry/repo-metrics](https://github.com/getsentry/repo-metrics) | Fast local git repository metrics and visualizations, straight from the repo |

| Cask | Source | Description |
| --- | --- | --- |
| `dex-ui` | [ryan953/dex-ui](https://github.com/ryan953/dex-ui) (private) | Tasks.app — native macOS app for dex tasks and assigned Linear issues |

## Casks from a private repository

`dex-ui` lives in a private repository, so its release download URL answers 404
for everyone, with or without a token. The cask fetches the release asset
through the GitHub API instead, which does accept a token.

To install it you need a token in the environment:

```sh
export HOMEBREW_GITHUB_API_TOKEN=<a token that can read ryan953/dex-ui>
brew install --cask ryan953/tap/dex-ui
```

The token needs **Contents: Read** on the source repository. A fine-grained
token with only metadata access reads the repository fine but is refused on the
release asset, with `Resource not accessible by personal access token`. A
classic token with `repo`, or the token from `gh auth token`, works.

Because the asset is private, the API names it by a numeric asset ID rather
than by version. The ID changes with every release, so use
`scripts/bump-cask.sh` rather than editing the URL by hand.

`Tasks.app` is ad-hoc signed, not notarized. On a Mac with Gatekeeper
assessment enabled, add `--no-quarantine` or macOS refuses to open it:

```sh
brew install --cask --no-quarantine ryan953/tap/dex-ui
```

Signing and notarizing the app in `ryan953/dex-ui` would remove the need for
that flag. Making that repository public would remove the need for the token
and let CI test the cask.

## Add a new formula

1. Give the source repository a tagged release with these assets:

   - `<name>-v<version>-aarch64-apple-darwin.tar.gz`
   - `<name>-v<version>-x86_64-apple-darwin.tar.gz`
   - `<name>-v<version>-x86_64-unknown-linux-gnu.tar.gz` (optional)

   Each archive must hold the executable file at its top level. Homebrew moves
   into the single top-level directory before it runs `install`.

2. Copy `Formula/repo-metrics.rb` to `Formula/<name>.rb`. Change the class name
   to the CamelCase form of the formula name, then change `desc`, `homepage`,
   `license`, the URLs, and the `install` and `test` blocks.

   Do not add a `version` line. Homebrew reads the version out of the URL, and
   `brew audit` rejects the duplicate.

   Every platform must resolve to a URL. `brew readall` loads each formula for
   macOS and Linux, on arm64 and x86_64, and a platform with no URL fails the
   check. If the project ships no binary for one of them, point that platform at
   the nearest archive and add `depends_on arch: :x86_64`, so Homebrew refuses
   the install instead of unpacking the wrong binary. `Formula/repo-metrics.rb`
   does this for arm64 Linux.

3. Fill in the checksums without doing it by hand. Put any older version in the
   URLs, then run:

   ```sh
   scripts/bump-formula.sh <name> <version>
   ```

4. Add a row to the table above.

## Add a new cask

1. Release the application as a `.zip` holding `<Name>.app` at its top level.

2. Copy `Casks/dex-ui.rb` to `Casks/<token>.rb`. Change the token on the first
   line, then `name`, `desc`, `homepage`, `depends_on macos:`, the `app` line
   and the `zap` paths.

   `desc` takes no leading article and no full stop. Use
   `depends_on macos: :sonoma`, not `">= :sonoma"`, which is deprecated.

   The URL must carry the version somewhere, or `brew audit` demands
   `sha256 :no_check` and gives up on verifying the download. The asset ID
   names no version, so `Casks/dex-ui.rb` ends its URL with `?v=#{version}`.
   GitHub ignores the parameter.

3. Fill in the asset ID and the checksum:

   ```sh
   scripts/bump-cask.sh <token> <version>
   ```

4. Add a row to the table above.

## Update to a new version

```sh
scripts/bump-formula.sh repo-metrics 0.3.0
scripts/bump-cask.sh dex-ui 1.1.0
git commit -am "repo-metrics 0.3.0"
git push
```

`bump-formula.sh` reads the current version out of the release URLs, replaces
it, downloads each asset, and writes the new `sha256` values.

`bump-cask.sh` looks up the release by tag, finds the one downloadable asset,
and writes the version, the new asset ID and the `sha256`.

For a formula you can also do this from GitHub: **Actions → Bump formula → Run
workflow**. That does not work for a cask from a private repository, because
the runner's token cannot read it. Bump those locally.

## Check your work

```sh
brew install --formula ryan953/tap/<name>
brew test ryan953/tap/<name>
brew audit --strict ryan953/tap/<name>

brew install --cask ryan953/tap/<token>
brew audit --cask --strict ryan953/tap/<token>
```

The `brew test-bot` workflow does the same on each push and pull request, on
macOS and Linux.

## Notes

- These formulae install prebuilt release binaries. They do not build from
  source, and they are not bottled. The CI therefore skips
  `brew test-bot --only-formulae` and installs each formula by name instead.
- CI checks the style, syntax and audit of every cask, but does not install
  one. The runner has no access to a private source repository.
- The tap is public because `brew tap` needs read access without a token. The
  cask being public gives nothing away; the download still needs a token.
- `brew style` runs `shfmt` over `scripts/`, and `shfmt` truncates a file it
  cannot parse. It cannot parse a heredoc inside `$( )`, so multi-line Python
  lives in its own file, `scripts/pick_release_asset.py`. Check `bash -n` after
  running `brew style --fix` on a shell script.
- Your local clone of the tap is at
  `$(brew --repository)/Library/Taps/ryan953/homebrew-tap`. It is the same
  git repository, so you can edit and push from there too.
