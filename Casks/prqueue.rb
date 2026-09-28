cask "prqueue" do
  version "1.2.0"
  sha256 "3aab8f559c1e8e6ff2c34ffe446072ece71bef6296d325db02c47feddb03b19f"

  url "https://github.com/ryan953/prqueue/releases/download/v#{version}/PRQueue-#{version}-macos-universal.zip"
  name "PR Queue"
  desc "Sorts your GitHub pull request review queue into lanes"
  homepage "https://github.com/ryan953/prqueue"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "PRQueue.app"

  # The app reads the `gh` CLI's token rather than holding a login of its own,
  # so there is no keychain item to clean up here.
  zap trash: [
    "~/Library/Application Support/PRQueue",
    "~/Library/Caches/com.ryan953.prqueue",
    "~/Library/Preferences/com.ryan953.prqueue.plist",
    "~/Library/Saved Application State/com.ryan953.prqueue.savedState",
  ]
end
