cask "worktrees-ui" do
  version "0.1.0"
  sha256 "92af2b096889a1b425ba9538bc4a486989fe2c68710276df29f0ca6c43d8926d"

  url "https://github.com/ryan953/worktrees-ui/releases/download/v#{version}/Worktrees-#{version}-macos-universal.zip"
  name "Worktrees"
  desc "Lists git worktrees and which ones hold unpushed work"
  homepage "https://github.com/ryan953/worktrees-ui"

  depends_on macos: :sonoma

  app "Worktrees.app"

  zap trash: [
    "~/Library/Caches/com.ryan953.worktrees-ui",
    "~/Library/Preferences/com.ryan953.worktrees-ui.plist",
    "~/Library/Saved Application State/com.ryan953.worktrees-ui.savedState",
  ]
end
