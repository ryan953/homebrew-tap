# homebrew-tap

A personal Homebrew tap for software by [@ryan953](https://github.com/ryan953).

## Install

```sh
brew tap ryan953/tap
brew install ryan953/tap/repo-metrics
brew install --cask ryan953/tap/tasks-ui
brew install --cask ryan953/tap/bg-monitor
brew install --cask ryan953/tap/prqueue
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

Every source repository is public, so nothing here needs a token to install.

The apps are ad-hoc signed rather than notarized. On a Mac with Gatekeeper
assessment enabled, add `--no-quarantine` or macOS refuses to open them:

```sh
brew install --cask --no-quarantine ryan953/tap/tasks-ui
```

Signing and notarizing them would remove the need for that flag.

## What is in the tap

Formulae are command-line programs. Casks are macOS applications.

| Formula | Source | Description |
| --- | --- | --- |
| `repo-metrics` | [getsentry/repo-metrics](https://github.com/getsentry/repo-metrics) | Fast local git repository metrics and visualizations, straight from the repo |

| Cask | App | Source | Description |
| --- | --- | --- | --- |
| `tasks-ui` | `Tasks.app` | [ryan953/tasks-ui](https://github.com/ryan953/tasks-ui) | Native macOS app for dex tasks and assigned Linear issues |
| `bg-monitor` | `BGMonitor.app` | [ryan953/launch-agent-monitor](https://github.com/ryan953/launch-agent-monitor) | Menu bar app to inspect and control LaunchAgents |
| `worktrees-ui` | `Worktrees.app` | [ryan953/worktrees-ui](https://github.com/ryan953/worktrees-ui) | Lists git worktrees and which ones hold unpushed work |
| `prqueue` | `PRQueue.app` | [ryan953/prqueue](https://github.com/ryan953/prqueue) | Sorts your GitHub pull request review queue into lanes |

The cask token does not always match its repository. `bg-monitor` comes from
`launch-agent-monitor`, and `tasks-ui` was called `dex-ui` until the repository
was renamed. `tap_migrations.json` moves an existing `dex-ui` install across, so
`brew upgrade` follows the rename on its own.

## The tap keeps itself up to date

Two mechanisms, and an entry can use both.

**Push, on release.** A source repository calls
`.github/workflows/bump.yml` here when it publishes a release, so the tap
follows within a minute or two:

```yaml
jobs:
  tap:
    needs: release
    uses: ryan953/homebrew-tap/.github/workflows/bump.yml@main
    with: { kind: cask, name: tasks-ui, version: "${{ needs.release.outputs.tag }}" }
    secrets:
      TAP_TOKEN: ${{ secrets.TAP_TOKEN }}
```

That job hangs off the release rather than listening for `release: published`.
The event never fires: GitHub suppresses workflow triggers for anything a
`GITHUB_TOKEN` did, and those releases are created with `github.token`.

**Pull, daily.** `sync.yml` runs `scripts/sync.sh`, which reads each entry's
`homepage`, asks GitHub for the latest release, and bumps whatever is behind.
Every source is public, so this needs no credentials at all and covers formulae
and casks alike.

The pull is what makes a missed push survivable, and it is not hypothetical: a
`launch-agent-monitor` release shipped while `TAP_TOKEN` was unset, the push
failed, and the cask sat at the old version until someone noticed. A repository
that pushes still benefits from the daily sweep behind it.

Check what would move without changing anything:

```sh
scripts/sync.sh --dry-run
```

Either way the bump logic lives here, in `scripts/`, and is never copied into a
project. That is what stops the entries drifting apart.

### The TAP_TOKEN secret

Only repositories that **push** need this, and only to write here — a
repository's own `github.token` is scoped to itself and cannot push to another
repository. Since every source is public, the token no longer needs read access
to the source, so a fine-grained token scoped to `ryan953/homebrew-tap` with
**Contents: Read and write** is enough.

```sh
gh secret set TAP_TOKEN -R ryan953/tasks-ui
gh secret set TAP_TOKEN -R ryan953/launch-agent-monitor
gh secret set TAP_TOKEN -R ryan953/worktrees-ui
```

Without it the bump job fails with a message saying so, the release itself still
stands, and the daily sync picks the version up within a day.

`getsentry/repo-metrics` is a work repository and is deliberately not coupled to
this personal space: it holds no token for the tap and references no workflow
from it. The daily pull is how it stays in step.

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

4. Add a row to the table above. `sync.sh` picks it up from then on.

## Add a new cask

1. Release the application as a `.zip` holding `<Name>.app` at its top level.

2. Copy `Casks/prqueue.rb` to `Casks/<token>.rb`. Change the token on the first
   line, then `name`, `desc`, `homepage`, `depends_on macos:`, the `app` line
   and the `zap` paths.

   `desc` takes no leading article and no full stop. Use
   `depends_on macos: :sonoma`, not `">= :sonoma"`, which is deprecated.

   Interpolate `#{version}` into the URL. `brew audit` demands
   `sha256 :no_check` for a URL that names no version, which gives up on
   verifying the download. Mind that the asset filename is whatever the
   project's release workflow writes: `BGMonitor-v0.1.0-…` carries the leading
   `v` and `Tasks-1.0.0-…` does not.

   `scripts/bump-cask.sh` and `scripts/sync.sh` both read the source repository
   out of the `homepage` line, so that line has to point at the real repository.

3. Fill in the version and the checksum:

   ```sh
   scripts/bump-cask.sh <token> <version>
   ```

4. Add a row to the table above. `sync.sh` picks it up from then on.

## Update to a new version by hand

This happens on its own. Do it by hand only to repair a bump that failed:

```sh
scripts/bump-formula.sh repo-metrics 0.3.0
scripts/bump-cask.sh tasks-ui 1.1.0
git commit -am "repo-metrics 0.3.0"
git push
```

Both scripts resolve the download URL first and only edit the file once the
fetch has succeeded, so a bad version leaves the entry alone rather than
half-rewritten.

You can also do this from GitHub: **Actions → Bump → Run workflow**, choosing
`formula` or `cask`, or **Actions → Sync** to sweep everything at once.

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
- CI installs every cask on macOS as well, which a runner can do because every
  source repository is public.
- The tap is public because `brew tap` needs read access without a token. A
  reusable workflow in a public repository can also be called from another
  repository, which is what lets a project push a bump here.
- `brew style` runs `shfmt` over `scripts/`, and `shfmt` truncates a file it
  cannot parse. It cannot parse a heredoc inside `$( )`, so keep multi-line
  Python or SQL out of a command substitution, and check `bash -n` after running
  `brew style --fix` on a shell script.
- Your local clone of the tap is at
  `$(brew --repository)/Library/Taps/ryan953/homebrew-tap`. It is the same
  git repository, so you can edit and push from there too.
