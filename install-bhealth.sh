#!/bin/bash
# install-bhealth.sh — one-time installer for the bhealth weekly auto-audit on this Mac.
#
# What it does:
#   1. Figures out where B-Suite actually lives on THIS Mac (no hardcoded paths)
#   2. Generates a LaunchAgent that runs bhealth.sh in --ensure-weekly mode:
#      - RunAtLoad: fires on every login/boot (so opening a closed laptop or
#        powering on a desktop triggers a check immediately)
#      - StartCalendarInterval: also fires daily at 8:00 AM
#   3. Installs it to ~/Library/LaunchAgents/ and loads it
#   4. Verifies it's running
#
# Why this schedule:
#   bhealth's --ensure-weekly flag checks $BSUITE_DIR/.bhealth-last-run-epoch.
#   If a successful run happened within the last 6 days, it exits silently.
#   Otherwise it runs and updates the marker. So firing daily-plus-on-boot
#   is cheap (most invocations are no-ops) and guarantees a fresh report
#   lands in bhub the first time the Mac is online during any given week —
#   even if the Mac was completely off through any specific scheduled time.
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
        <string>--ensure-weekly</string>
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
    <key>RunAtLoad</key>
    <true/>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>8</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
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
  echo "   Schedule:   On every login/boot + daily at 8:00 AM (--ensure-weekly mode)"
  echo "               Runs only if > 6 days since last successful run, else exits silently."
  echo "   Reader:     Monday 8:04 AM (weekly-fleet-audit-check scheduled task)"
  echo "   Log output: $LOG_STDOUT"
  echo "   Log errors: $LOG_STDERR"
  echo ""
  echo "   To force a run right now (ignores the 6-day guard):"
  echo "     bash $BHEALTH_SH"
  echo "   To trigger the agent itself (respects the guard):"
  echo "     launchctl start com.bsuite.bhealth"
else
  echo ""
  echo "⚠️  Install wrote the config but the LaunchAgent isn't loaded."
  echo "   Check manually: launchctl list | grep bsuite"
  exit 1
fi
