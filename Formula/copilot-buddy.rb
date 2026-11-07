class CopilotBuddy < Formula
  desc "Bridge between the GitHub Copilot CLI and a BLE Copilot Buddy device"
  homepage "https://github.com/Loopdesk-AI/homebrew-tap"
  version "0.22.1"
  license "MIT"

  # Prebuilt release binaries (no Rust toolchain needed). The source lives in a
  # private repo; these tarballs are published to the public tap by CI. macOS
  # tarballs contain a CopilotBuddy.app bundle so the daemon can obtain Bluetooth.
  on_macos do
    on_arm do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.22.1/copilot-buddy-0.22.1-aarch64-apple-darwin.tar.gz"
      sha256 "c6d8f00dc2ff073edde0f56be1379e8a67666f8fd3996d9789820ec6ad1ba012"
    end
    on_intel do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.22.1/copilot-buddy-0.22.1-x86_64-apple-darwin.tar.gz"
      sha256 "4bf235c493f7d8492160ed83a1640f2439356467ed109be36f080560ae987b69"
    end
  end
  on_linux do
    on_intel do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.22.1/copilot-buddy-0.22.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a9cd44788a04d923aa7e158abe166719256777d92bdb217bfcb284f2de46dbd0"
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
