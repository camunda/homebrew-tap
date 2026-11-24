class C8ctl < Formula
  desc "Camunda 8 CLI"
  homepage "https://github.com/camunda/c8ctl"
  url "https://registry.npmjs.org/@camunda8/cli/-/cli-4.6.1.tgz"
  sha256 "c830488a30f9e84d0b9a54dea84c5b5e8ba579a34a1fcc5af18edf60876114c6"
  license "MIT"

  # `.github/workflows/update.yml` bumps url and sha256 when @camunda8/cli
  # publishes a new `latest`.
  livecheck do
    url "https://registry.npmjs.org/@camunda8/cli/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*") # c8ctl and c8
  end

  test do
    assert_match "c8ctl v#{version}", shell_output("#{bin}/c8ctl --version")
    assert_match "Usage: c8ctl", shell_output("#{bin}/c8 --help")
  end
end
