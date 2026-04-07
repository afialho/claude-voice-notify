#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude/scripts"
SETTINGS="$HOME/.claude/settings.json"

echo "🔊 Claude Voice Notify — Installer"
echo ""

# --- Check macOS ---
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This tool requires macOS (uses 'say' for voice synthesis)."
    exit 1
fi

# --- Install terminal-notifier ---
if ! command -v terminal-notifier &>/dev/null; then
    echo "📦 Installing terminal-notifier..."
    if command -v brew &>/dev/null; then
        brew install terminal-notifier
    else
        echo "⚠️  Homebrew not found. Install terminal-notifier manually:"
        echo "   brew install terminal-notifier"
        echo "   (banner notifications will be skipped without it)"
    fi
else
    echo "✅ terminal-notifier already installed"
fi

# --- Copy scripts ---
mkdir -p "$DEST"
cp "$SCRIPT_DIR/scripts/voice-notify.sh" "$DEST/"
cp "$SCRIPT_DIR/scripts/voice-timestamp.sh" "$DEST/"
chmod +x "$DEST/voice-notify.sh" "$DEST/voice-timestamp.sh"
echo "✅ Scripts copied to $DEST"

# --- Merge hooks into settings.json ---
if [ ! -f "$SETTINGS" ]; then
    echo "{}" > "$SETTINGS"
fi

# Use python3 (ships with macOS) to safely merge JSON
python3 << 'PYEOF'
import json, sys, os

settings_path = os.path.expanduser("~/.claude/settings.json")

with open(settings_path, "r") as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})
scripts_dir = os.path.expanduser("~/.claude/scripts")

new_hooks = {
    "PreToolUse": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": f"{scripts_dir}/voice-timestamp.sh",
                    "async": True
                }
            ]
        }
    ],
    "Notification": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": f"{scripts_dir}/voice-notify.sh waiting",
                    "async": True
                }
            ]
        }
    ],
    "Stop": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": f"{scripts_dir}/voice-notify.sh done",
                    "async": True
                }
            ]
        }
    ]
}

MARKER = "voice-notify"

for event, entries in new_hooks.items():
    existing = hooks.get(event, [])
    # Remove previous voice-notify hooks (idempotent reinstall)
    existing = [e for e in existing if MARKER not in json.dumps(e)]
    existing.extend(entries)
    hooks[event] = existing

settings["hooks"] = hooks

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("✅ Hooks added to", settings_path)
PYEOF

echo ""
echo "🎉 Done! Claude Code will now:"
echo "   🔈 Speak the project name when done or waiting"
echo "   🔔 Show a macOS banner notification"
echo ""
echo "💡 Configure with environment variables:"
echo "   CLAUDE_NOTIFY_THRESHOLD=15  — min seconds before notifying (default: 15)"
echo "   CLAUDE_NOTIFY_VOICE=Samantha — macOS voice (default: Samantha)"
echo "   CLAUDE_NOTIFY_RATE=200      — speech rate (default: 200)"
echo ""
echo "🗑  To uninstall: ./uninstall.sh"
