cask "worktrees-ui" do
  version "0.1.0"
  sha256 "92af2b096889a1b425ba9538bc4a486989fe2c68710276df29f0ca6c43d8926d"

  # The source is private, where a plain release download URL answers 404 even
  # with a token; only the API asset endpoint accepts one. That endpoint names
  # the asset by an ID carrying no version, and audit demands a version in the
  # URL, hence the query parameter GitHub ignores. Needs
  # HOMEBREW_GITHUB_API_TOKEN with `repo` scope to install.
  url "https://api.github.com/repos/ryan953/worktrees-ui/releases/assets/538400829?v=#{version}",
      header: [
        "Accept: application/octet-stream",
        "Authorization: Bearer #{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)}",
      ]
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
