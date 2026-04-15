import { parseArgs } from "./cli";

const { subcommand } = parseArgs(process.argv.slice(2));

switch (subcommand) {
  case "hook": {
    const { hookCommand } = await import("./hook");
    await hookCommand();
    break;
  }
  case "status": {
    const { statusCommand } = await import("./statusline");
    await statusCommand();
    break;
  }
  case "install": {
    const { installCommand } = await import("./install");
    await installCommand();
    break;
  }
  case "tui": {
    const { startTui } = await import("./tui");
    await startTui();
    break;
  }
}
