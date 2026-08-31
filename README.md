# homebrew-tap

A personal Homebrew tap for software by [@ryan953](https://github.com/ryan953).

## Install

```sh
brew tap ryan953/tap
brew install ryan953/tap/repo-metrics
brew install --cask ryan953/tap/tasks-ui
brew install --cask ryan953/tap/bg-monitor
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

| Cask | App | Source | Description |
| --- | --- | --- | --- |
| `tasks-ui` | `Tasks.app` | [ryan953/tasks-ui](https://github.com/ryan953/tasks-ui) (private) | Native macOS app for dex tasks and assigned Linear issues |
| `bg-monitor` | `BGMonitor.app` | [ryan953/launch-agent-monitor](https://github.com/ryan953/launch-agent-monitor) (private) | Menu bar app to inspect and control LaunchAgents |

The cask token does not always match its repository. `bg-monitor` comes from
`launch-agent-monitor`, and `tasks-ui` was called `dex-ui` until the repository
was renamed. `tap_migrations.json` moves an existing `dex-ui` install across, so
`brew upgrade` follows the rename on its own.

## A release bumps the tap on its own

Each source repository calls `.github/workflows/bump.yml` in this tap when it
publishes a release. That workflow checks out the tap, runs the same bump script
you would run by hand, and pushes the result. Nobody has to remember to update a
version here.

```
tasks-ui             release: published ─┐
launch-agent-monitor release: published ─┼─> ryan953/homebrew-tap  Bump  ─> commit
repo-metrics         release: published ─┘
```

The bump logic lives here, in `scripts/`, and not in each project, so the three
projects cannot drift apart. A project only says which kind it is and what it is
called:

```yaml
jobs:
  bump:
    uses: ryan953/homebrew-tap/.github/workflows/bump.yml@main
    with:
      kind: cask          # or: formula
      name: tasks-ui
      version: ${{ github.event.release.tag_name }}
    secrets:
      TAP_TOKEN: ${{ secrets.TAP_TOKEN }}
```

### The TAP_TOKEN secret

A repository's own `github.token` is scoped to that repository, so it cannot
push here. Each source repository needs a `TAP_TOKEN` secret instead:

- **Contents: Read and write** on `ryan953/homebrew-tap`, to push the bump.
- **Contents: Read** on the source repository, because a cask bump downloads the
  release asset to checksum it.

A classic token with `repo` covers both. Set it once per repository:

```sh
gh secret set TAP_TOKEN -R ryan953/tasks-ui
gh secret set TAP_TOKEN -R ryan953/launch-agent-monitor
gh secret set TAP_TOKEN -R getsentry/repo-metrics
```

Without the secret the bump job fails with a message that says so, and the
release itself still stands. Bump the tap by hand afterwards.

## Casks from a private repository

Both casks live in private repositories, so their release download URLs answer
404 for everyone, with or without a token. The casks fetch the release asset
through the GitHub API instead, which does accept a token.

To install either one you need a token in the environment:

```sh
export HOMEBREW_GITHUB_API_TOKEN=<a token that can read the source repository>
brew install --cask ryan953/tap/tasks-ui
```

The token needs **Contents: Read** on the source repository. A fine-grained
token with only metadata access reads the repository fine but is refused on the
release asset, with `Resource not accessible by personal access token`. A
classic token with `repo`, or the token from `gh auth token`, works.

Because the asset is private, the API names it by a numeric asset ID rather
than by version. The ID changes with every release, so use
`scripts/bump-cask.sh` rather than editing the URL by hand.

Both apps are ad-hoc signed, not notarized. On a Mac with Gatekeeper assessment
enabled, add `--no-quarantine` or macOS refuses to open them:

```sh
brew install --cask --no-quarantine ryan953/tap/tasks-ui
```

Signing and notarizing the apps would remove the need for that flag. Making
those repositories public would remove the need for the token and let CI test
the casks.

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

4. Add a row to the table above, and add the `bump.yml` caller shown earlier to
   the source repository.

## Add a new cask

1. Release the application as a `.zip` holding `<Name>.app` at its top level.

2. Copy `Casks/tasks-ui.rb` to `Casks/<token>.rb`. Change the token on the first
   line, then `name`, `desc`, `homepage`, `depends_on macos:`, the `app` line
   and the `zap` paths.

   `desc` takes no leading article and no full stop. Use
   `depends_on macos: :sonoma`, not `">= :sonoma"`, which is deprecated.

   The URL must carry the version somewhere, or `brew audit` demands
   `sha256 :no_check` and gives up on verifying the download. The asset ID
   names no version, so the casks here end their URL with `?v=#{version}`.
   GitHub ignores the parameter.

   `scripts/bump-cask.sh` reads the source repository out of the `homepage`
   line, so that line has to point at the real repository.

3. Fill in the asset ID and the checksum:

   ```sh
   scripts/bump-cask.sh <token> <version>
   ```

4. Add a row to the table above, and add the `bump.yml` caller shown earlier to
   the source repository.

## Update to a new version by hand

A release does this on its own. Do it by hand only to repair a bump that failed:

```sh
scripts/bump-formula.sh repo-metrics 0.3.0
scripts/bump-cask.sh tasks-ui 1.1.0
git commit -am "repo-metrics 0.3.0"
git push
```

`bump-formula.sh` reads the current version out of the release URLs, replaces
it, downloads each asset, and writes the new `sha256` values.

`bump-cask.sh` looks up the release by tag, finds the one downloadable asset,
and writes the version, the new asset ID and the `sha256`.

You can also do this from GitHub: **Actions → Bump → Run workflow**, choosing
`formula` or `cask`. Unlike the old formula-only workflow, that now works for a
cask from a private repository too, as long as `TAP_TOKEN` is set here.

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
- The tap is public because `brew tap` needs read access without a token. A
  reusable workflow in a public repository can also be called from a private
  one, which is what lets the private projects bump the tap.
- The cask being public gives nothing away; the download still needs a token.
- `brew style` runs `shfmt` over `scripts/`, and `shfmt` truncates a file it
  cannot parse. It cannot parse a heredoc inside `$( )`, so multi-line Python
  lives in its own file, `scripts/pick_release_asset.py`. Check `bash -n` after
  running `brew style --fix` on a shell script.
- Your local clone of the tap is at
  `$(brew --repository)/Library/Taps/ryan953/homebrew-tap`. It is the same
  git repository, so you can edit and push from there too.
