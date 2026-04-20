import AppKit

final class TickerController {
    private var subviews: [NSView] = []
    private weak var containerView: NSView?
    private var lastContentSnapshot: String = ""
    var onSessionCountChanged: ((Int) -> Void)?

    func attach(to view: NSView) {
        containerView = view
    }

    func update(sessions: [Session]) {
        guard let container = containerView else { return }

        let sorted = TickerView.sortedSessions(sessions)
        let snapshot = TickerView.snapshotString(sessions: sorted)
        if snapshot == lastContentSnapshot {
            return
        }
        lastContentSnapshot = snapshot

        // Clear
        for v in subviews { v.removeFromSuperview() }
        subviews.removeAll()

        onSessionCountChanged?(sorted.count)

        let panelWidth = container.bounds.width
        let rowHeight: CGFloat = 44
        let padding: CGFloat = 8
        let hPadding: CGFloat = 14

        if sorted.isEmpty {
            let field = makeLabel()
            field.attributedStringValue = NSAttributedString(
                string: "No active sessions",
                attributes: [
                    .foregroundColor: NSColor.black.withAlphaComponent(0.4),
                    .font: NSFont.systemFont(ofSize: 12, weight: .medium),
                ]
            )
            field.alignment = .center
            field.frame = NSRect(x: 0, y: 0, width: panelWidth, height: container.bounds.height)
            container.addSubview(field)
            subviews.append(field)
            return
        }

        let totalHeight = CGFloat(sorted.count) * rowHeight + padding * 2

        for (i, session) in sorted.enumerated() {
            // Rows stack top-down: top row = last index in flipped-less NSView coords
            let y = totalHeight - padding - CGFloat(i + 1) * rowHeight

            // Title line
            let title = makeLabel()
            title.attributedStringValue = TickerView.titleLine(session)
            title.frame = NSRect(x: hPadding, y: y + 22, width: panelWidth - hPadding * 2, height: 18)
            container.addSubview(title)
            subviews.append(title)

            // Detail line
            let detail = makeLabel()
            detail.attributedStringValue = TickerView.detailLine(session)
            detail.frame = NSRect(x: hPadding + 18, y: y + 4, width: panelWidth - hPadding * 2 - 18, height: 16)
            container.addSubview(detail)
            subviews.append(detail)

            // Separator between sessions (not after last)
            if i < sorted.count - 1 {
                let sep = NSView(frame: NSRect(
                    x: hPadding,
                    y: y - 0.5,
                    width: panelWidth - hPadding * 2,
                    height: 1
                ))
                sep.wantsLayer = true
                sep.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.1).cgColor
                container.addSubview(sep)
                subviews.append(sep)
            }
        }
    }

    private func makeLabel() -> NSTextField {
        let field = NSTextField(labelWithString: "")
        field.isEditable = false
        field.isSelectable = false
        field.isBordered = false
        field.drawsBackground = false
        field.lineBreakMode = .byTruncatingTail
        field.maximumNumberOfLines = 1
        field.cell?.truncatesLastVisibleLine = true
        return field
    }
}
