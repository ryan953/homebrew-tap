class RepoMetrics < Formula
  desc "Fast local git repository metrics and visualizations, straight from the repo"
  homepage "https://github.com/getsentry/repo-metrics"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/getsentry/repo-metrics/releases/download/v0.2.0/repo-metrics-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "6f5be1ec123e8697db601a8ac63a3f29fa03d709181a8d805925eaf73bcfc37d"
    end

    on_intel do
      url "https://github.com/getsentry/repo-metrics/releases/download/v0.2.0/repo-metrics-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "78c54b34504477f6da1560f9f888182e60c79c808a3052e74372d8b591de5d6e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/getsentry/repo-metrics/releases/download/v0.2.0/repo-metrics-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "efb77c3a78b4a4b75c89f79c90488e1cabf820dc5bf6b4b7a4ac903c50d6e629"
    end

    # There is no aarch64 Linux release. Homebrew needs every platform to
    # resolve to a URL, so name the x86_64 archive and let the arch requirement
    # refuse the install instead of unpacking the wrong binary.
    on_arm do
      url "https://github.com/getsentry/repo-metrics/releases/download/v0.2.0/repo-metrics-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "efb77c3a78b4a4b75c89f79c90488e1cabf820dc5bf6b4b7a4ac903c50d6e629"
      depends_on arch: :x86_64
    end
  end

  def install
    bin.install "repo-metrics"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/repo-metrics --version")
  end
end
