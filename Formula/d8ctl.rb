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
      url "https://github.com/camunda/d8ctl/releases/download/v0.13.0/d8ctl-darwin-arm64"
      sha256 "cd3f83a89f3bbf7c6297272ca718a9110ad4e887980f348b5751f3fdfe573d1e"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.13.0/d8ctl-darwin-amd64"
      sha256 "03bb3e2d87fe62e586b3478ce2d8988f2caf3311036dd8e8805a305ac8965e4d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.13.0/d8ctl-linux-arm64"
      sha256 "5d1c417ed0f27bbbcc1540487f7b2e67ae83bf949ab25febcfa8ef1e4f67d24e"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.13.0/d8ctl-linux-amd64"
      sha256 "5331a9eadc795c8c1237aefbb935208936c2726828f1abc1879b5c97ff2fe523"
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
