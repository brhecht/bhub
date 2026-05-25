#!/bin/bash
# install-bhealth.sh — one-time installer for the bhealth weekly auto-audit on this Mac.
#
# What it does:
#   1. Figures out where B-Suite actually lives on THIS Mac (no hardcoded paths)
#   2. Generates a LaunchAgent that runs bhealth.sh weekly (Sun 11pm + Mon 7am catch-up)
#   3. Installs it to ~/Library/LaunchAgents/ and loads it
#   4. Verifies it's running
#
# The two-window schedule is intentional: macOS launchd fires the next eligible
# StartCalendarInterval entry when the Mac wakes from sleep, so Mon 7am catches
# Macs that were asleep Sunday night. The Monday reader scheduled task fires
# 8:04 AM, so reports are fresh.
#
# Safe to re-run at any time — unloads any existing copy before installing fresh.
#
# Usage:
#   bash install-bhealth.sh

set -e

echo "=== Installing bhealth weekly auto-audit ==="
echo ""

# --- Self-locate bhub and bhealth.sh ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSUITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BHEALTH_SH="$SCRIPT_DIR/bhealth.sh"

if [[ ! -f "$BHEALTH_SH" ]]; then
  echo "❌ Can't find bhealth.sh at: $BHEALTH_SH"
  echo "   Make sure you're running this from inside B-Suite/bhub/"
  exit 1
fi

# --- Require .bhealth-device — bhealth.sh prompts interactively if missing,
#     which would hang the launchd run. Force the user to set it once manually.
DEVICE_FILE="$BSUITE_DIR/.bhealth-device"
if [[ ! -f "$DEVICE_FILE" ]]; then
  echo "❌ $DEVICE_FILE not found."
  echo "   Run bhealth.sh manually once to set this Mac's device name, then re-run this installer."
  echo "   (bhealth.sh prompts on first run and writes the answer to .bhealth-device.)"
  exit 1
fi

echo "Detected bhub location:     $SCRIPT_DIR"
echo "Detected B-Suite location:  $BSUITE_DIR"
echo "Detected bhealth script:    $BHEALTH_SH"
echo "This Mac's device name:     $(cat "$DEVICE_FILE")"
echo ""

PLIST_PATH="$HOME/Library/LaunchAgents/com.bsuite.bhealth.plist"
LOG_STDOUT="$BSUITE_DIR/.bhealth-stdout.log"
LOG_STDERR="$BSUITE_DIR/.bhealth-stderr.log"

# --- Unload any existing LaunchAgent (safe if not present) ---
if launchctl list 2>/dev/null | grep -q com.bsuite.bhealth; then
  echo "Unloading existing bhealth LaunchAgent..."
  launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi

# --- Generate the plist ---
# PATH includes both Homebrew prefixes (Apple Silicon /opt/homebrew/bin and
# Intel /usr/local/bin) plus user-local bins so bhealth's tool detection sees
# node/npm/gh/vercel correctly. Without an explicit PATH, launchd jobs only
# get /usr/bin:/bin:/usr/sbin:/sbin.
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.bsuite.bhealth</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$BHEALTH_SH</string>
        <string>--quiet</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>BSUITE_DIR</key>
        <string>$BSUITE_DIR</string>
        <key>HOME</key>
        <string>$HOME</string>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Weekday</key>
            <integer>0</integer>
            <key>Hour</key>
            <integer>23</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>7</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </array>
    <key>StandardOutPath</key>
    <string>$LOG_STDOUT</string>
    <key>StandardErrorPath</key>
    <string>$LOG_STDERR</string>
</dict>
</plist>
EOF

echo "Wrote config to: $PLIST_PATH"

# --- Load it ---
launchctl load "$PLIST_PATH"

# --- Verify ---
sleep 1
if launchctl list 2>/dev/null | grep -q com.bsuite.bhealth; then
  echo ""
  echo "✅ bhealth is installed on this Mac."
  echo ""
  echo "   Schedule:   Sunday 11:00 PM + Monday 7:00 AM (catch-up if Sun missed)"
  echo "   Reader:     Monday 8:04 AM (weekly-fleet-audit-check scheduled task)"
  echo "   Log output: $LOG_STDOUT"
  echo "   Log errors: $LOG_STDERR"
  echo ""
  echo "   To kick off a test run right now (optional):"
  echo "     launchctl start com.bsuite.bhealth"
  echo "   Or run manually:"
  echo "     bash $BHEALTH_SH"
else
  echo ""
  echo "⚠️  Install wrote the config but the LaunchAgent isn't loaded."
  echo "   Check manually: launchctl list | grep bsuite"
  exit 1
fi
