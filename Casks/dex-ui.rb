cask "dex-ui" do
  version "1.0.0"
  sha256 "cfefc6cd1b01406caf27876b39c333561c7e0af51854ca9d179b1a1277507395"

  # dex-ui is a private repository, so its release download URL answers 404 for
  # everyone, with or without a token. The API asset endpoint does accept a
  # token, so fetch through that. Export HOMEBREW_GITHUB_API_TOKEN with `repo`
  # scope before you install.
  #
  # The number is the release asset ID, which changes with every release, and
  # names no version on its own. GitHub ignores the trailing query parameter,
  # so it is there to record which release this ID belongs to.
  # `scripts/bump-cask.sh` looks up the new ID for you.
  url "https://api.github.com/repos/ryan953/dex-ui/releases/assets/534286514?v=#{version}",
      header: [
        "Accept: application/octet-stream",
        "Authorization: Bearer #{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)}",
      ]
  name "Tasks"
  desc "Native app for dex tasks and assigned Linear issues"
  homepage "https://github.com/ryan953/dex-ui"

  depends_on macos: :sonoma

  app "Tasks.app"

  zap trash: [
    "~/Library/Caches/com.ryan953.dex-ui",
    "~/Library/Preferences/com.ryan953.dex-ui.plist",
    "~/Library/Saved Application State/com.ryan953.dex-ui.savedState",
  ]
end
