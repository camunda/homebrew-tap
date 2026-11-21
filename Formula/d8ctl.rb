class D8ctl < Formula
  desc "One CLI for every Camunda API, built for agents"
  homepage "https://camunda.github.io/d8ctl/"
  version "0.9.2"
  license "Apache-2.0"

  # Prebuilt release binaries; `.github/workflows/update.yml` bumps the version
  # and checksums (from each asset's .sha256 sidecar) when camunda/d8ctl releases.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.9.2/d8ctl-darwin-arm64"
      sha256 "dad7c458077e3f6949306290b9c5f62f3548ee40eee952e6c966a0babcfba7c0"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.9.2/d8ctl-darwin-amd64"
      sha256 "49a45aac8f55e93531a6dd3f1124fbdc25ac19d6f1e9313148898602411822bd"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/camunda/d8ctl/releases/download/v0.9.2/d8ctl-linux-arm64"
      sha256 "902d9bb0a5002e6c6ea30668444acc9f75bd56dafd52e1d8995ebfd4243331a9"
    end
    on_intel do
      url "https://github.com/camunda/d8ctl/releases/download/v0.9.2/d8ctl-linux-amd64"
      sha256 "8eb38ad3343de0d818af78a65fc901e94cf35c4be3ce47f24a3f2ff4f2624c58"
    end
  end

  # Releases are flagged pre-release while d8ctl is 0.x, which the
  # :github_releases strategy skips, so check tags.

  def install
    bin.install Dir["d8ctl-*"].first => "d8ctl"
  end

  test do
    assert_match "d8ctl #{version} ", shell_output("#{bin}/d8ctl --version")
    # No server needed: a refused connection is a structured network error (exit 7).
    output = shell_output("#{bin}/d8ctl cluster topology get --camunda-rest-address=http://127.0.0.1:9 2>&1", 7)
    assert_match "\"kind\":\"network\"", output
  end
end
