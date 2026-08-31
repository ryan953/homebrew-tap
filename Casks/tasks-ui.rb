cask "tasks-ui" do
  version "1.0.0"
  sha256 "cfefc6cd1b01406caf27876b39c333561c7e0af51854ca9d179b1a1277507395"

  # The source is private, where a plain release download URL answers 404 even
  # with a token; only the API asset endpoint accepts one. That endpoint names
  # the asset by an ID carrying no version, and audit demands a version in the
  # URL, hence the query parameter GitHub ignores. Needs
  # HOMEBREW_GITHUB_API_TOKEN with `repo` scope to install.
  url "https://api.github.com/repos/ryan953/tasks-ui/releases/assets/534286514?v=#{version}",
      header: [
        "Accept: application/octet-stream",
        "Authorization: Bearer #{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)}",
      ]
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
