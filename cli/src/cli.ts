export type Subcommand = "tui" | "hook" | "status" | "install";

export interface ParsedArgs {
  subcommand: Subcommand;
}

export function parseArgs(args: string[]): ParsedArgs {
  const positional = args.filter((a) => !a.startsWith("--"));
  const sub = positional[0];

  let subcommand: Subcommand;
  switch (sub) {
    case "hook":
      subcommand = "hook";
      break;
    case "status":
      subcommand = "status";
      break;
    case "install":
      subcommand = "install";
      break;
    default:
      subcommand = "tui";
      break;
  }

  return { subcommand };
}
