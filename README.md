# homebrew-tap

A personal Homebrew tap for software by [@ryan953](https://github.com/ryan953).

## Install

```sh
brew tap ryan953/tap
brew install ryan953/tap/repo-metrics
```

Homebrew 6 trusts a third-party formula the first time you install it by its
full name. To trust the whole tap once, and every formula added to it later:

```sh
brew trust --tap ryan953/tap
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
brew install --formula ryan953/tap/<name>
brew test ryan953/tap/<name>
brew audit --strict ryan953/tap/<name>
```

The `brew test-bot` workflow does the same on each push and pull request, on
macOS and Linux.

## Notes

- These formulae install prebuilt release binaries. They do not build from
  source, and they are not bottled. The CI therefore skips
  `brew test-bot --only-formulae` and installs each formula by name instead.
- The tap is public because `brew tap` needs read access without a token.
- Your local clone of the tap is at
  `$(brew --repository)/Library/Taps/ryan953/homebrew-tap`. It is the same
  git repository, so you can edit and push from there too.
