cask "tasks-ui" do
  version "1.1.0"
  sha256 "673a43b40ba8b93f0caf53671447ef1ccd5ac47b77e3339569535a81ada18cdc"

  url "https://github.com/ryan953/tasks-ui/releases/download/v#{version}/Tasks-#{version}-macos-universal.zip"
  name "Tasks"
  desc "Native app for dex tasks and assigned Linear issues"
  homepage "https://github.com/ryan953/tasks-ui"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Tasks.app"

  # These follow the bundle identifier, which does not match the cask token.
  zap trash: [
    "~/Library/Caches/com.ryan953.dex-ui",
    "~/Library/Preferences/com.ryan953.dex-ui.plist",
    "~/Library/Saved Application State/com.ryan953.dex-ui.savedState",
  ]

  # The CLI is a convenience, not a requirement, so it is documented rather than
  # declared as a dependency: the app reads a key from Settings first and only
  # falls back to the CLI, and a cask dependency would force the install.
  caveats <<~EOS
    Tasks borrows an API key from the `linear` CLI when it is installed and
    logged in, so there is nothing to configure:

      brew install schpet/tap/linear
      linear auth login

    Otherwise put a personal API key in Settings -> Linear. A key set there
    is kept in the login keychain and takes precedence over the CLI.
  EOS
end
