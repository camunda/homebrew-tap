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
      url "https://github.com/camunda/d8ctl/releases/download/v0.12.0/d8ctl-darwin-arm64"
      sha256 "447871e9c42aebfad2475ad154f9ea28bc32d6633a8d9038cf09b364f5863c1f"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.12.0/d8ctl-darwin-amd64"
      sha256 "3c1a0a5126f034782f505072a93e63019be978a0bfe4ff946ce58bf148d9af2c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.12.0/d8ctl-linux-arm64"
      sha256 "39a8e0c72b154b2774768ddfa30b3739cfe78ab97558fdc9a6dd7593d4dc5fdf"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.12.0/d8ctl-linux-amd64"
      sha256 "6cddfa117cd4f28ff8556bed28cfac017b1ad080ca798a31c6142547c0be92e5"
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
