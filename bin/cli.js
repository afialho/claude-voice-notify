#!/usr/bin/env node

const { install } = require("../lib/install");
const { uninstall } = require("../lib/uninstall");
const { checkDeps } = require("../lib/deps");

const command = process.argv[2] || "install";

async function main() {
  console.log("");
  console.log("  🔊 Claude Voice Notify");
  console.log("");

  switch (command) {
    case "install":
      checkDeps();
      install();
      break;
    case "uninstall":
      uninstall();
      break;
    case "check":
      checkDeps();
      console.log("  ✅ All good!");
      break;
    default:
      console.log("  Usage: claude-voice-notify [install|uninstall|check]");
      process.exit(1);
  }
}

main();
