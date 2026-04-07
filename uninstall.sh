#!/bin/bash
set -e

DEST="$HOME/.claude/scripts"
SETTINGS="$HOME/.claude/settings.json"

echo "🔊 Claude Voice Notify — Uninstaller"
echo ""

# --- Remove scripts ---
rm -f "$DEST/voice-notify.sh" "$DEST/voice-timestamp.sh"
echo "✅ Scripts removed"

# --- Remove hooks from settings.json ---
if [ -f "$SETTINGS" ]; then
    python3 << 'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")

with open(settings_path, "r") as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
MARKER = "voice-notify"

for event in list(hooks.keys()):
    hooks[event] = [e for e in hooks[event] if MARKER not in json.dumps(e)]
    if not hooks[event]:
        del hooks[event]

settings["hooks"] = hooks

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("✅ Hooks removed from", settings_path)
PYEOF
fi

echo ""
echo "🗑  Uninstalled. Restart Claude Code for changes to take effect."
