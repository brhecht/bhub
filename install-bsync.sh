#!/bin/bash
# install-bsync.sh — one-time installer for the bsync hourly auto-pull on this Mac.
#
# What it does:
#   1. Figures out where B-Suite actually lives on THIS Mac (no hardcoded paths)
#   2. Generates a LaunchAgent config with this Mac's real paths
#   3. Installs it to ~/Library/LaunchAgents/ and loads it
#   4. Verifies it's running
#
# Safe to re-run at any time — it unloads any existing copy before installing fresh.
#
# Usage:
#   bash install-bsync.sh

set -e

echo "=== Installing bsync hourly auto-pull ==="
echo ""

# --- Self-locate bhub and bsync.sh ---
# This script lives inside bhub/, alongside bsync.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSUITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BSYNC_SH="$SCRIPT_DIR/bsync.sh"

if [[ ! -f "$BSYNC_SH" ]]; then
  echo "❌ Can't find bsync.sh at: $BSYNC_SH"
  echo "   Make sure you're running this from inside B-Suite/bhub/"
  exit 1
fi

echo "Detected bhub location:     $SCRIPT_DIR"
echo "Detected B-Suite location:  $BSUITE_DIR"
echo "Detected bsync script:      $BSYNC_SH"
echo ""

PLIST_PATH="$HOME/Library/LaunchAgents/com.bsuite.bsync.plist"
LOG_STDOUT="$BSUITE_DIR/.bsync-stdout.log"
LOG_STDERR="$BSUITE_DIR/.bsync-stderr.log"

# --- Unload any existing LaunchAgent (safe if not present) ---
if launchctl list 2>/dev/null | grep -q com.bsuite.bsync; then
  echo "Unloading existing bsync LaunchAgent..."
  launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi

# --- Generate the plist with THIS Mac's actual paths ---
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.bsuite.bsync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$BSYNC_SH</string>
        <string>--pull-only</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>BSUITE_DIR</key>
        <string>$BSUITE_DIR</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>3600</integer>
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
if launchctl list 2>/dev/null | grep -q com.bsuite.bsync; then
  echo ""
  echo "✅ bsync is installed and running hourly on this Mac."
  echo ""
  echo "   Next pull: within the next minute (first run on load)"
  echo "   Recurring: every 60 minutes"
  echo "   Log output: $LOG_STDOUT"
  echo "   Log errors: $LOG_STDERR"
  echo ""
  echo "   To verify later, check the log files above — they'll grow as pulls run."
else
  echo ""
  echo "⚠️  Install wrote the config but the LaunchAgent isn't loaded."
  echo "   Check manually: launchctl list | grep bsuite"
  exit 1
fi
