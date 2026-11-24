class D8ctl < Formula
  desc "One CLI for every Camunda API, built for agents"
  homepage "https://camunda.github.io/d8ctl/"
  license "Apache-2.0"

  # Prebuilt release binaries; `.github/workflows/update.yml` bumps the version
  # and checksums (from each asset's .sha256 sidecar) when camunda/d8ctl releases.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.2/d8ctl-darwin-arm64"
      sha256 "8731765b7ef02de900afff641846e589d80472d473dd059ee0e66d6ee7881d40"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.2/d8ctl-darwin-amd64"
      sha256 "f12d9efe50104127bf3b16ebcaf9ab7890ba66d1311980be734e6ea8edcae2b6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.2/d8ctl-linux-arm64"
      sha256 "3f1c8f96976619372e1bd8b0c4f306015aa1e1aa77daecf55b5e3637ffb9c95c"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.2/d8ctl-linux-amd64"
      sha256 "2ee0594a858b47a43003b3cdd40cbd89239bc9192eeab8c38d5cb355d88a4c03"
    end
  end

  # Releases are flagged pre-release while d8ctl is 0.x, which the
  # :github_releases strategy skips, so check tags.

  def install
    bin.install Dir["d8ctl-*"].first => "d8ctl"
    # Release assets are bare binaries; the download doesn't keep the exec bit.
    chmod 0755, bin/"d8ctl"
    generate_completions_from_executable(bin/"d8ctl", "completion")
  end

  test do
    assert_match "d8ctl #{version} ", shell_output("#{bin}/d8ctl --version")
    assert_match "topology", shell_output("#{bin}/d8ctl __complete cluster topo")
    # No server needed: a refused connection is a structured network error (exit 7).
    output = shell_output("#{bin}/d8ctl cluster topology get --camunda-rest-address=http://127.0.0.1:9 2>&1", 7)
    assert_match "\"kind\":\"network\"", output
  end
end
