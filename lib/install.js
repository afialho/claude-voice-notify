const fs = require("fs");
const path = require("path");
const os = require("os");

const SCRIPTS_SRC = path.join(__dirname, "..", "scripts");
const CLAUDE_DIR = path.join(os.homedir(), ".claude");
const SCRIPTS_DEST = path.join(CLAUDE_DIR, "scripts");
const SETTINGS_PATH = path.join(CLAUDE_DIR, "settings.json");

const MARKER = "voice-notify";

function getHooks() {
  const scriptsDir = SCRIPTS_DEST;
  return {
    PreToolUse: [
      {
        hooks: [
          {
            type: "command",
            command: `${scriptsDir}/voice-timestamp.sh`,
            async: true,
          },
        ],
      },
    ],
    Notification: [
      {
        hooks: [
          {
            type: "command",
            command: `${scriptsDir}/voice-notify.sh waiting`,
            async: true,
          },
        ],
      },
    ],
    Stop: [
      {
        hooks: [
          {
            type: "command",
            command: `${scriptsDir}/voice-notify.sh done`,
            async: true,
          },
        ],
      },
    ],
  };
}

function install() {
  // Copy scripts
  fs.mkdirSync(SCRIPTS_DEST, { recursive: true });

  for (const file of ["voice-notify.sh", "voice-timestamp.sh"]) {
    const src = path.join(SCRIPTS_SRC, file);
    const dest = path.join(SCRIPTS_DEST, file);
    fs.copyFileSync(src, dest);
    fs.chmodSync(dest, 0o755);
  }
  console.log(`  ✅ Scripts copied to ${SCRIPTS_DEST}`);

  // Merge hooks into settings.json
  let settings = {};
  if (fs.existsSync(SETTINGS_PATH)) {
    settings = JSON.parse(fs.readFileSync(SETTINGS_PATH, "utf8"));
  }

  const hooks = settings.hooks || {};
  const newHooks = getHooks();

  for (const [event, entries] of Object.entries(newHooks)) {
    let existing = hooks[event] || [];
    // Remove previous voice-notify hooks (idempotent)
    existing = existing.filter(
      (e) => !JSON.stringify(e).includes(MARKER)
    );
    existing.push(...entries);
    hooks[event] = existing;
  }

  settings.hooks = hooks;
  fs.writeFileSync(SETTINGS_PATH, JSON.stringify(settings, null, 2) + "\n");
  console.log(`  ✅ Hooks added to ${SETTINGS_PATH}`);

  console.log("");
  console.log("  🎉 Installed! Restart Claude Code for changes to take effect.");
  console.log("");
  console.log("  Configure with environment variables:");
  console.log("    CLAUDE_NOTIFY_THRESHOLD=15   min seconds before notifying");
  console.log("    CLAUDE_NOTIFY_VOICE=Samantha  macOS voice (say -v '?' to list)");
  console.log("    CLAUDE_NOTIFY_RATE=200        speech rate (words per minute)");
  console.log("");
  console.log("  To uninstall: npx claude-voice-notify uninstall");
}

module.exports = { install };
