// Generated from cctop/src/types.ts — do not edit manually.
// Run: bun generate-models.ts

import Foundation

enum SessionState: String, Codable {
    case working = "working"
    case waitingPermission = "waiting:permission"
    case waitingInput = "waiting:input"
}

struct Session: Codable, Identifiable {
    var id: String { sessionId }

    let sessionId: String
    var cwd: String
    var state: SessionState
    var currentTool: String?
    var model: String?
    var costUsd: Double
    var contextPct: Double
    var startedAt: String?
    var lastUpdatedAt: String
    var pid: Int?
}
