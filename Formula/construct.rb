class Construct < Formula
  desc "Track tasks and their pull requests through one state machine"
  homepage "https://github.com/ryan953/construct"

  depends_on "gh"

  on_macos do
    on_arm do
      url "https://github.com/ryan953/construct/releases/download/v0.1.0/construct-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "80ccf38aefc47286ef50fa5e600556b709f7acea51b99fa51f2f052360a54210"
    end

    on_intel do
      url "https://github.com/ryan953/construct/releases/download/v0.1.0/construct-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "885173fb30bd3e94fc07767eebce70264f63d663155b13cd3ccc281b90f48dd6"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/ryan953/construct/releases/download/v0.1.0/construct-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a2c6aeae587d627c46b04a620c8be9cc271f8cea5e60890470f3059d476866f5"
    end

    # There is no aarch64 Linux build. Homebrew needs every platform to resolve
    # to a URL, so name the x86_64 archive and let the arch requirement refuse
    # the install instead of unpacking the wrong binary.
    on_arm do
      url "https://github.com/ryan953/construct/releases/download/v0.1.0/construct-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a2c6aeae587d627c46b04a620c8be9cc271f8cea5e60890470f3059d476866f5"
      depends_on arch: :x86_64
    end
  end

  def install
    bin.install "construct", "ct"
  end

  def caveats
    <<~EOS
      Finish setting up: the database, the launch agent that syncs your PRs,
      and the Claude Code skills.

        gh auth login     # if you haven't
        construct setup

      After `brew upgrade construct`, run `construct skills install` so the
      skills match the new version. The launch agent follows the upgrade on
      its own.
    EOS
  end

  test do
    assert_match "construct #{version}", shell_output("#{bin}/construct --version")
    ENV["CONSTRUCT_GH"] = "off"
    system bin/"construct", "--db", testpath/"construct.db", "task", "add", "Try construct"
    assert_match "Try construct", shell_output("#{bin}/ct --db #{testpath}/construct.db task list")
  end
end
