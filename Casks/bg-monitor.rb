cask "bg-monitor" do
  version "0.1.0"
  sha256 "538d55fe64f8fa234d3c75837448bb04c1385496a227c15e7e7b264852eaf4fe"

  url "https://github.com/ryan953/launch-agent-monitor/releases/download/v#{version}/BGMonitor-v#{version}-macos-universal.zip"
  name "BG Monitor"
  desc "Menu bar app to inspect and control LaunchAgents"
  homepage "https://github.com/ryan953/launch-agent-monitor"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "BGMonitor.app"

  zap trash: [
    "~/Library/Caches/com.ryan953.bgmonitor",
    "~/Library/Preferences/com.ryan953.bgmonitor.plist",
    "~/Library/Saved Application State/com.ryan953.bgmonitor.savedState",
  ]
end
