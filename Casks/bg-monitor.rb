cask "bg-monitor" do
  version "0.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  # launch-agent-monitor is a private repository, so its release download URL
  # answers 404 for everyone, with or without a token. The API asset endpoint
  # does accept a token, so fetch through that. Export HOMEBREW_GITHUB_API_TOKEN
  # with `repo` scope before you install.
  #
  # The number is the release asset ID, which changes with every release, and
  # names no version on its own. GitHub ignores the trailing query parameter,
  # so it is there to record which release this ID belongs to.
  # `scripts/bump-cask.sh` looks up the new ID for you, and the release workflow
  # in launch-agent-monitor runs that script for you on every release.
  url "https://api.github.com/repos/ryan953/launch-agent-monitor/releases/assets/0?v=#{version}",
      header: [
        "Accept: application/octet-stream",
        "Authorization: Bearer #{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)}",
      ]
  name "BG Monitor"
  desc "Menu bar app to inspect and control LaunchAgents"
  homepage "https://github.com/ryan953/launch-agent-monitor"

  depends_on macos: :sonoma

  app "BGMonitor.app"

  zap trash: [
    "~/Library/Caches/com.ryan953.bgmonitor",
    "~/Library/Preferences/com.ryan953.bgmonitor.plist",
    "~/Library/Saved Application State/com.ryan953.bgmonitor.savedState",
  ]
end
