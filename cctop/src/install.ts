import { existsSync, readFileSync, writeFileSync } from "fs";
import { dirname } from "path";
import { mkdirSync } from "fs";
import { paths } from "./paths";

const HOOK_EVENTS = [
  "SessionStart",
  "SessionEnd",
  "PreToolUse",
  "PostToolUse",
  "Stop",
  "Notification",
  "UserPromptSubmit",
] as const;

const CCTOP_HOOK = { type: "command" as const, command: "cctop hook" };

interface HookEntry {
  matcher?: string;
  hooks: { type: string; command?: string; prompt?: string; timeout?: number }[];
}

function hasCctopHook(entries: HookEntry[]): boolean {
  return entries.some((entry) =>
    entry.hooks.some((h) => h.type === "command" && h.command === "cctop hook")
  );
}

export async function installCommand(): Promise<void> {
  // Read existing settings
  let settings: Record<string, unknown> = {};

  if (existsSync(paths.claudeSettings)) {
    try {
      settings = JSON.parse(readFileSync(paths.claudeSettings, "utf-8"));
    } catch (e) {
      console.error(`Error reading ${paths.claudeSettings}: ${e}`);
      process.exit(1);
    }
  } else {
    mkdirSync(dirname(paths.claudeSettings), { recursive: true });
  }

  // Merge hooks — nested under "hooks" key in settings.json
  let hooksAdded = 0;

  // Remove any stale top-level hook keys from previous installs
  for (const event of HOOK_EVENTS) {
    if (event in settings) {
      delete settings[event];
    }
  }

  const hooksObj = (settings.hooks ?? {}) as Record<string, HookEntry[]>;
  settings.hooks = hooksObj;

  for (const event of HOOK_EVENTS) {
    const existing = hooksObj[event] ?? [];

    if (hasCctopHook(existing)) {
      console.log(`  ✓ ${event} hook already installed`);
      continue;
    }

    const hookEntry: HookEntry =
      event === "PreToolUse" || event === "PostToolUse"
        ? { matcher: ".*", hooks: [CCTOP_HOOK] }
        : { hooks: [CCTOP_HOOK] };

    existing.push(hookEntry);
    hooksObj[event] = existing;
    hooksAdded++;
    console.log(`  + ${event} hook added`);
  }

  // Status line
  const existingStatus = settings.statusLine as { command?: string } | undefined;
  if (existingStatus?.command === "cctop status") {
    console.log(`  ✓ statusLine already configured`);
  } else if (existingStatus) {
    console.log(
      `  ⚠ statusLine already set to: ${existingStatus.command ?? JSON.stringify(existingStatus)}`
    );
    console.log(`    Replace with 'cctop status'? Updating...`);
    settings.statusLine = { type: "command", command: "cctop status" };
  } else {
    settings.statusLine = { type: "command", command: "cctop status" };
    console.log(`  + statusLine configured`);
  }

  // Write back
  writeFileSync(paths.claudeSettings, JSON.stringify(settings, null, 2) + "\n");

  console.log(`\nSettings written to ${paths.claudeSettings}`);
  if (hooksAdded > 0) {
    console.log(`${hooksAdded} hook(s) added.`);
  }

  // Check if cctop is in PATH
  const which = Bun.spawnSync(["which", "cctop"]);
  if (which.exitCode !== 0) {
    console.log(
      "\n⚠ 'cctop' not found in PATH. Make sure to add the compiled binary to your PATH."
    );
    console.log("  Build with: bun run build");
    console.log("  Then copy the binary: cp cctop /usr/local/bin/");
  } else {
    console.log(`\ncctop binary found at: ${which.stdout.toString().trim()}`);
  }

  console.log("\nDone! Start cctop in one terminal, then use Claude Code in another.");
}
