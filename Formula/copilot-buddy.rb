class CopilotBuddy < Formula
  desc "Bridge between the GitHub Copilot CLI and a BLE Copilot Buddy device"
  homepage "https://github.com/Loopdesk-AI/homebrew-tap"
  version "0.21.0"
  license "MIT"

  # Prebuilt release binaries (no Rust toolchain needed). The source lives in a
  # private repo; these tarballs are published to the public tap by CI. macOS
  # tarballs contain a CopilotBuddy.app bundle so the daemon can obtain Bluetooth.
  on_macos do
    on_arm do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.21.0/copilot-buddy-0.21.0-aarch64-apple-darwin.tar.gz"
      sha256 "2c41f53d3df4a104efccdaccbfd7578304a23c6194e846ff64c4249135d50567"
    end
    on_intel do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.21.0/copilot-buddy-0.21.0-x86_64-apple-darwin.tar.gz"
      sha256 "011173e03626da610980a77c181f370866e808f07f6357ed7bc19871270becf5"
    end
  end
  on_linux do
    on_intel do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.21.0/copilot-buddy-0.21.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "9f64828aaf403d81da334d3f6c67e43914ba4016d4f521a59beed00dec08da9e"
    end
  end

  def install
    if OS.mac?
      # Release tarball already contains the signed CopilotBuddy.app.
      prefix.install "CopilotBuddy.app"
      bin.install_symlink prefix/"CopilotBuddy.app/Contents/MacOS/copilot-buddy"
      bin.install_symlink prefix/"CopilotBuddy.app/Contents/MacOS/copilot-buddyd"
    else
      bin.install "copilot-buddyd", "copilot-buddy"
    end
  end

  # `brew services start copilot-buddy` == `copilot-buddy service install`. On macOS
  # the daemon runs from the .app bundle so the Bluetooth permission prompt works.
  service do
    if OS.mac?
      run [opt_prefix/"CopilotBuddy.app/Contents/MacOS/copilot-buddyd", "--source", "hooks"]
    else
      run [opt_bin/"copilot-buddyd", "--source", "hooks"]
    end
    keep_alive true
    log_path var/"log/copilot-buddy.log"
    error_log_path var/"log/copilot-buddy.err.log"
    environment_variables RUST_LOG: "info", COPILOT_HOOK_ALLOW_LOCALHOST: "1"
  end

  def caveats
    <<~EOS
      Finish setup with the guided wizard:
        copilot-buddy setup

      On macOS, click "Allow" when prompted for Bluetooth.
      Start at login with:  brew services start copilot-buddy
    EOS
  end

  test do
    assert_match "copilot-buddy", shell_output("#{bin}/copilot-buddy --help")
  end
end
