import Foundation

struct SessionParser {
    static var sessionsDir: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.config/ccwatch/sessions"
    }

    private static func isProcessAlive(_ pid: Int) -> Bool {
        let ret = kill(pid_t(pid), 0)
        return ret == 0 || (ret == -1 && errno == EPERM)
    }

    /// Reads all session JSON files from ~/.config/ccwatch/sessions/.
    /// Filters out dead sessions in memory (by PID check) but never deletes files —
    /// cleanup is solely the responsibility of ccwatch hooks and the TUI.
    static func loadSessions() -> [Session] {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: sessionsDir) else { return [] }

        let decoder = JSONDecoder()
        var sessions: [Session] = []

        for file in files where file.hasSuffix(".json") {
            let path = "\(sessionsDir)/\(file)"
            guard let data = fm.contents(atPath: path),
                  let session = try? decoder.decode(Session.self, from: data)
            else { continue }

            // Skip dead sessions in memory only — never delete the file.
            if let pid = session.pid, !isProcessAlive(pid) {
                continue
            }

            sessions.append(session)
        }

        return sessions
    }
}
