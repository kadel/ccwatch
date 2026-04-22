import { watch, type FSWatcher } from "fs";
import { paths } from "./paths.js";

export type ChangeCallback = () => void;

export class FileWatcher {
  private watchers: FSWatcher[] = [];
  private callback: ChangeCallback;
  private debounceTimer: ReturnType<typeof setTimeout> | null = null;
  private debounceMs = 100;

  constructor(callback: ChangeCallback) {
    this.callback = callback;
  }

  start(): void {
    try {
      const watcher = watch(paths.sessionsDir, () => {
        this.scheduleCallback();
      });
      this.watchers.push(watcher);
    } catch {
      // Directory may not exist yet
    }
  }

  private scheduleCallback(): void {
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.callback();
    }, this.debounceMs);
  }

  stop(): void {
    for (const w of this.watchers) {
      w.close();
    }
    this.watchers = [];
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
  }
}
