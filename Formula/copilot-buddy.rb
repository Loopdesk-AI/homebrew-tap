class CopilotBuddy < Formula
  desc "Bridge between the GitHub Copilot CLI and a BLE Copilot Buddy device"
  homepage "https://github.com/Loopdesk-AI/homebrew-tap"
  version "0.16.0"
  license "MIT"

  # Prebuilt release binaries (no Rust toolchain needed). The source lives in a
  # private repo; these tarballs are published to the public tap by CI. macOS
  # tarballs contain a CopilotBuddy.app bundle so the daemon can obtain Bluetooth.
  on_macos do
    on_arm do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.16.0/copilot-buddy-0.16.0-aarch64-apple-darwin.tar.gz"
      sha256 "60aaa45ea1344a51092c794b4748e71bb03b4aa18ebd8cc21c453e534c7fea6d"
    end
    on_intel do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.16.0/copilot-buddy-0.16.0-x86_64-apple-darwin.tar.gz"
      sha256 "fb19dcf58f9005f62bc8565b155ed9393040f13f3c31d71346d8548dd34a50cc"
    end
  end
  on_linux do
    on_intel do
      url "https://github.com/Loopdesk-AI/homebrew-tap/releases/download/copilot-buddyd-v0.16.0/copilot-buddy-0.16.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e639f83898168bb3104112105558038f066d87953b2a2743e4354871634da7f5"
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
