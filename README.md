# Copilot Buddy — Homebrew tap

Public Homebrew tap for **Copilot Buddy**, the BLE desk companion for the GitHub
Copilot CLI. This repo holds only the formula and the prebuilt release binaries; the
source is private. Formula + releases are published automatically by CI.

## Install

```bash
brew tap loopdesk-ai/tap
brew install copilot-buddy
copilot-buddy setup        # guided setup: hooks, Bluetooth, service, connectivity test
```

On macOS, click **Allow** when prompted for Bluetooth. Start at login with
`brew services start copilot-buddy`.
