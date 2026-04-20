import AppKit

struct TickerView {
    static func sortedSessions(_ sessions: [Session]) -> [Session] {
        sessions
            .sorted { a, b in stateOrder(a.state) < stateOrder(b.state) }
    }

    static func snapshotString(sessions: [Session]) -> String {
        sessions.map { s in
            "\(s.sessionId)|\(s.state.rawValue)|\(s.cwd)|\(s.model ?? "")|\(s.costUsd)|\(s.contextPct)|\(s.currentTool ?? "")|\(s.lastUpdatedAt)"
        }.joined(separator: "\n")
    }

    // Line 1: icon + project name
    static func titleLine(_ session: Session) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let icon = stateIcon(session.state)
        let project = projectName(session.cwd)

        result.append(NSAttributedString(
            string: "\(icon) ",
            attributes: [
                .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            ]
        ))

        result.append(NSAttributedString(
            string: project,
            attributes: [
                .foregroundColor: NSColor.black,
                .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            ]
        ))

        return result
    }

    // Line 2: model · cost · ctx%  · tool
    static func detailLine(_ session: Session) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let dimBlack = NSColor.black.withAlphaComponent(0.55)
        let font = NSFont.systemFont(ofSize: 11, weight: .regular)
        let sep = " \u{00B7} "

        var parts: [String] = []

        if let model = session.model, !model.isEmpty {
            parts.append(model)
        }

        parts.append(String(format: "$%.2f", session.costUsd))
        parts.append("ctx:\(Int(session.contextPct))%")

        if let tool = session.currentTool, !tool.isEmpty {
            parts.append(tool)
        }

        let joined = parts.joined(separator: sep)
        result.append(NSAttributedString(
            string: joined,
            attributes: [.foregroundColor: dimBlack, .font: font]
        ))

        return result
    }

    private static func stateOrder(_ state: SessionState) -> Int {
        switch state {
        case .working: return 0
        case .waitingPermission: return 1
        case .waitingInput: return 2
        }
    }

    private static func stateIcon(_ state: SessionState) -> String {
        switch state {
        case .working: return "🔨"
        case .waitingPermission: return "🔐"
        case .waitingInput: return "⌨️"
        }
    }

    private static func projectName(_ cwd: String) -> String {
        if cwd.isEmpty { return "unknown" }
        return (cwd as NSString).lastPathComponent
    }
}
