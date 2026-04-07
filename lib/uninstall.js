const fs = require("fs");
const path = require("path");
const os = require("os");

const SCRIPTS_DEST = path.join(os.homedir(), ".claude", "scripts");
const SETTINGS_PATH = path.join(os.homedir(), ".claude", "settings.json");

const MARKER = "voice-notify";

function uninstall() {
  // Remove scripts
  const exts = os.platform() === "win32" ? ["ps1"] : ["sh"];
  const files = exts.flatMap((ext) => [`voice-notify.${ext}`, `voice-timestamp.${ext}`]);
  for (const file of files) {
    const dest = path.join(SCRIPTS_DEST, file);
    if (fs.existsSync(dest)) fs.unlinkSync(dest);
  }
  console.log("  ✅ Scripts removed");

  // Remove hooks from settings.json
  if (fs.existsSync(SETTINGS_PATH)) {
    const settings = JSON.parse(fs.readFileSync(SETTINGS_PATH, "utf8"));
    const hooks = settings.hooks || {};

    for (const event of Object.keys(hooks)) {
      hooks[event] = hooks[event].filter(
        (e) => !JSON.stringify(e).includes(MARKER)
      );
      if (hooks[event].length === 0) delete hooks[event];
    }

    settings.hooks = hooks;
    fs.writeFileSync(SETTINGS_PATH, JSON.stringify(settings, null, 2) + "\n");
    console.log(`  ✅ Hooks removed from ${SETTINGS_PATH}`);
  }

  console.log("");
  console.log("  🗑  Uninstalled. Restart Claude Code for changes to take effect.");
}

module.exports = { uninstall };
