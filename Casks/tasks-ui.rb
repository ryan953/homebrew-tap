cask "tasks-ui" do
  version "1.1.0"
  sha256 "673a43b40ba8b93f0caf53671447ef1ccd5ac47b77e3339569535a81ada18cdc"

  url "https://github.com/ryan953/tasks-ui/releases/download/v#{version}/Tasks-#{version}-macos-universal.zip"
  name "Tasks"
  desc "Native app for dex tasks and assigned Linear issues"
  homepage "https://github.com/ryan953/tasks-ui"

  depends_on macos: :sonoma

  app "Tasks.app"

  # These follow the bundle identifier, which does not match the cask token.
  zap trash: [
    "~/Library/Caches/com.ryan953.dex-ui",
    "~/Library/Preferences/com.ryan953.dex-ui.plist",
    "~/Library/Saved Application State/com.ryan953.dex-ui.savedState",
  ]
end
