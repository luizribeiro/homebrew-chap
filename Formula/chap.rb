class Chap < Formula
  desc "Consent-honoring coding agent with sandboxed tool execution"
  homepage "https://github.com/luizribeiro/chap"
  url "https://github.com/luizribeiro/chap/releases/download/v0.1.0/chap-0.1.0-aarch64-apple-darwin.tar.gz"
  version "0.1.0"
  sha256 "d0152f168a9a63cb75b12a1640ed1287c174ea620ed3f3ebd924bcd24e33d050"

  depends_on arch: :arm64
  depends_on :macos

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/chap"
  end

  def caveats
    <<~EOS
      Before the first run, create ~/.config/chap/chap.json by copying
      #{libexec}/share/chap/chap.json.in and replacing @CHAP_HOME@ with #{libexec}.

      chap only loads plugins approved with:
        chap grants review <plugin>
        chap grants approve <plugin>

      See https://github.com/luizribeiro/chap for details.
    EOS
  end

  test do
    # The wrapper prepares its sandbox state directory before running anything,
    # and the test sandbox HOME is longer than unix socket paths allow.
    ENV["MSB_HOME"] = "/private/tmp/chap-msb"
    assert_match "chap-cli 0.1.0", shell_output("#{bin}/chap --version")
  end
end
