class D8ctl < Formula
  desc "One CLI for every Camunda API, built for agents"
  homepage "https://camunda.github.io/d8ctl/"
  version "0.11.0"
  license "Apache-2.0"

  # Prebuilt release binaries; `.github/workflows/update.yml` bumps the version
  # and checksums (from each asset's .sha256 sidecar) when camunda/d8ctl releases.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.0/d8ctl-darwin-arm64"
      sha256 "1a4b6a2a7a7e24f4bcd6c29b18735a3bd1a9aee316334d725431389231dcbff4"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.0/d8ctl-darwin-amd64"
      sha256 "edacaa6b4acbc7b328158a8e28d3eebdc497041eaaa4937a1ad73ad8a9a75875"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.0/d8ctl-linux-arm64"
      sha256 "ed80d83c86117dc81bad8c421775e3aa017e51d32f89ba5a56ed4a043dcc3663"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.11.0/d8ctl-linux-amd64"
      sha256 "98096ec51e836ed0da06c0093af4e263d1776c140679969e7bb7be0f0a6325b4"
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
