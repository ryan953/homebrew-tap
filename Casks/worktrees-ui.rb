cask "worktrees-ui" do
  version "1.0.0"
  sha256 "8c655c7edaa9ea4ea2e5efb7e529b8c45b69a30bd210f6aa103bb07a80b88c3e"

  url "https://github.com/ryan953/worktrees-ui/releases/download/v#{version}/Worktrees-#{version}-macos-universal.zip"
  name "Worktrees"
  desc "Lists git worktrees and which ones hold unpushed work"
  homepage "https://github.com/ryan953/worktrees-ui"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Worktrees.app"

  zap trash: [
    "~/Library/Caches/com.ryan953.worktrees-ui",
    "~/Library/Preferences/com.ryan953.worktrees-ui.plist",
    "~/Library/Saved Application State/com.ryan953.worktrees-ui.savedState",
  ]
end
