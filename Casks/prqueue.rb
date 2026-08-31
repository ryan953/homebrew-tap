cask "prqueue" do
  version "1.1.0"
  sha256 "e01aa8e19ef900c97fac774f27c00e2caf2518eb3909d73b62fc445d8998486f"

  url "https://github.com/ryan953/prqueue/releases/download/v#{version}/PRQueue-#{version}-macos-universal.zip"
  name "PR Queue"
  desc "Sorts your GitHub pull request review queue into lanes"
  homepage "https://github.com/ryan953/prqueue"

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
