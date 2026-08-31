cask "bg-monitor" do
  version "0.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  # The source is private, where a plain release download URL answers 404 even
  # with a token; only the API asset endpoint accepts one. That endpoint names
  # the asset by an ID carrying no version, and audit demands a version in the
  # URL, hence the query parameter GitHub ignores. Needs
  # HOMEBREW_GITHUB_API_TOKEN with `repo` scope to install.
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
