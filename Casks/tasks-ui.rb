cask "tasks-ui" do
  version "1.0.0"
  sha256 "cfefc6cd1b01406caf27876b39c333561c7e0af51854ca9d179b1a1277507395"

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
