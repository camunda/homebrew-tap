class D8ctl < Formula
  desc "One CLI for every Camunda API, built for agents"
  homepage "https://camunda.github.io/d8ctl/"
  version "0.11.1"
  license "Apache-2.0"

  # Prebuilt release binaries; `.github/workflows/update.yml` bumps the version
  # and checksums (from each asset's .sha256 sidecar) when camunda/d8ctl releases.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.1/d8ctl-darwin-arm64"
      sha256 "7cf3f6b252f6f54d45c65f623c2fa1ddb9ca9e4b2c94828cabf8a8a73cccf74e"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.1/d8ctl-darwin-amd64"
      sha256 "2ae2e5374bdf45a9f3cfb23649954802906ff2a5888447dda3b0401d7d6ab7d8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.1/d8ctl-linux-arm64"
      sha256 "33f871ef0ff3cf8708ea00a3ee2b7bfb3f9700aa620dc04395e330b8498f4ad1"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.1/d8ctl-linux-amd64"
      sha256 "5364822d10bf3e963221081362565adb5c40a482ec0fd7645cc812a2f6a839e4"
    end
  end

  # Releases are flagged pre-release while d8ctl is 0.x, which the
  # :github_releases strategy skips, so check tags.

  def install
    bin.install Dir["d8ctl-*"].first => "d8ctl"
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
