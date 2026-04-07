const { execSync } = require("child_process");
const os = require("os");

function hasCommand(cmd) {
  try {
    execSync(`which ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function checkDeps() {
  const platform = os.platform();

  if (platform === "darwin") {
    // say is always available on macOS
    if (!hasCommand("terminal-notifier")) {
      console.log("  📦 Installing terminal-notifier...");
      if (hasCommand("brew")) {
        try {
          execSync("brew install terminal-notifier", { stdio: "inherit" });
        } catch {
          console.log(
            "  ⚠️  Could not install terminal-notifier. Banner notifications will use fallback."
          );
        }
      } else {
        console.log(
          "  ⚠️  Homebrew not found. Install terminal-notifier for banner notifications:"
        );
        console.log("     brew install terminal-notifier");
      }
    } else {
      console.log("  ✅ terminal-notifier");
    }
    console.log("  ✅ say (built-in)");
  } else if (platform === "linux") {
    // Voice
    const hasVoice = hasCommand("spd-say") || hasCommand("espeak") || hasCommand("espeak-ng");
    if (!hasVoice) {
      console.log("  ⚠️  No TTS engine found. Install one:");
      console.log("     sudo apt install speech-dispatcher  # for spd-say");
      console.log("     sudo apt install espeak-ng           # for espeak-ng");
    } else {
      const engine = hasCommand("spd-say") ? "spd-say" : hasCommand("espeak") ? "espeak" : "espeak-ng";
      console.log(`  ✅ ${engine}`);
    }

    // Banner
    if (!hasCommand("notify-send")) {
      console.log("  ⚠️  notify-send not found. Install for banner notifications:");
      console.log("     sudo apt install libnotify-bin");
    } else {
      console.log("  ✅ notify-send");
    }
  } else {
    console.log(`  ❌ Unsupported platform: ${platform}`);
    console.log("     Supported: macOS, Linux");
    process.exit(1);
  }
}

module.exports = { checkDeps, hasCommand };
