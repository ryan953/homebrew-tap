# homebrew-tap

A personal Homebrew tap for software by [@ryan953](https://github.com/ryan953).

## Install

```sh
brew tap freshghosts/tap
brew install freshghosts/tap/repo-metrics
```

Homebrew 6 trusts a third-party formula the first time you install it by its
full name. To trust the whole tap once, and every formula added to it later:

```sh
brew trust --tap freshghosts/tap
```

After that you can use short names:

```sh
brew install repo-metrics
brew upgrade repo-metrics
```

## Formulae

| Formula | Source | Description |
| --- | --- | --- |
| `repo-metrics` | [getsentry/repo-metrics](https://github.com/getsentry/repo-metrics) | Fast local git repository metrics and visualizations, straight from the repo |

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

3. Fill in the checksums without doing it by hand. Put any older version in the
   URLs, then run:

   ```sh
   scripts/bump-formula.sh <name> <version>
   ```

4. Add a row to the table above.

## Update a formula to a new version

```sh
scripts/bump-formula.sh repo-metrics 0.3.0
git commit -am "repo-metrics 0.3.0"
git push
```

The script reads the current version out of the release URLs, replaces it,
downloads each asset, and writes the new `sha256` values.

You can also do this from GitHub: **Actions → Bump formula → Run workflow**.
Give the formula name and the new version.

## Check your work

```sh
brew install --formula freshghosts/tap/<name>
brew test --formula freshghosts/tap/<name>
brew audit --strict freshghosts/tap/<name>
```

The `brew test-bot` workflow does the same on each push and pull request, on
macOS and Linux.

## Notes

- These formulae install prebuilt release binaries. They do not build from
  source, and they are not bottled.
- The tap is public because `brew tap` needs read access without a token.
- Your local clone of the tap is at
  `$(brew --repository)/Library/Taps/freshghosts/homebrew-tap`. It is the same
  git repository, so you can edit and push from there too.
