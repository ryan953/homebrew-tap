# homebrew-tap

A personal Homebrew tap for software by [@ryan953](https://github.com/ryan953).

## Install

```sh
brew tap freshghosts/tap
brew install freshghosts/tap/repo-metrics
```

After the tap is added you can use the short name:

```sh
brew install repo-metrics
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

   Each archive must contain the executable file at its top level.

2. Copy `Formula/repo-metrics.rb` to `Formula/<name>.rb`. Change the class name to
   the CamelCase form of the formula name, then change `desc`, `homepage`, `version`,
   the URLs, the checksums, and the `install` and `test` blocks.

3. Get the checksums without doing it by hand:

   ```sh
   scripts/bump-formula.sh <name> <version>
   ```

4. Add a row to the table above.

## Update a formula to a new version

Run the script, then commit:

```sh
scripts/bump-formula.sh repo-metrics 0.3.0
git commit -am "repo-metrics 0.3.0"
git push
```

The script replaces the old version string in the formula, downloads each URL, and
writes the new `sha256` values.

You can also do this from GitHub: **Actions → Bump formula → Run workflow**, then give
the formula name and the new version.

## Notes

- Formulae here install prebuilt binaries. They do not build from source.
- The tap is public because `brew tap` needs read access without a token.
- The `Test formulae` workflow installs, tests, and audits every formula on each push.
