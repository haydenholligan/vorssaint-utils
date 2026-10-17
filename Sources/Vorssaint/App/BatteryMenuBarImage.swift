// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit

/// Shared by the status item and its settings preview. The icon keeps a fixed
/// size in each mode; hiding the percentage gives the charge fill more room.
enum BatteryMenuBarImage {
    static func make(percent: Int,
                     isCharging: Bool,
                     showPercentage: Bool,
                     readable: Bool,
                     color: NSColor) -> NSImage {
        let charge = max(0, min(100, percent))
        let iconSize = showPercentage ? NSSize(width: 22, height: 11) : NSSize(width: 29, height: 15)
        let height: CGFloat = readable ? 22 : 20
        let font = NSFont.monospacedDigitSystemFont(ofSize: readable ? 13 : 12, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let value = "\(charge)%" as NSString
        let valueSize = value.size(withAttributes: attributes)
        let textWidth = showPercentage ? ("100%" as NSString).size(withAttributes: attributes).width : 0
        let gap: CGFloat = showPercentage ? (readable ? 5 : 4) : 0
        let size = NSSize(width: ceil(iconSize.width + gap + textWidth), height: height)
        let image = NSImage(size: size, flipped: false) { _ in
            color.setFill()
            color.setStroke()
            let body = NSRect(x: 0.75, y: (height - iconSize.height) / 2 + 0.75,
                              width: iconSize.width - 3.5, height: iconSize.height - 1.5)
            let outline = NSBezierPath(roundedRect: body, xRadius: 2, yRadius: 2)
            outline.lineWidth = 1.25
            outline.stroke()
            NSBezierPath(roundedRect: NSRect(x: iconSize.width - 1.75, y: height / 2 - 2,
                                            width: 1.5, height: 4), xRadius: 0.75, yRadius: 0.75).fill()

            let interior = body.insetBy(dx: 1.75, dy: 1.75)
            if charge > 0 {
                NSGraphicsContext.saveGraphicsState()
                NSBezierPath(roundedRect: interior, xRadius: 0.75, yRadius: 0.75).addClip()
                NSRect(x: interior.minX, y: interior.minY,
                       width: interior.width * CGFloat(charge) / 100, height: interior.height).fill()
                NSGraphicsContext.restoreGraphicsState()
            }

            if isCharging {
                // A transparent halo keeps the bolt legible across both the
                // filled and empty portions without assuming a menu bar color.
                let bolt = NSBezierPath()
                let cx = body.midX
                let cy = body.midY
                let h = iconSize.height * 0.43
                bolt.move(to: NSPoint(x: cx + 1.5, y: cy + h))
                bolt.line(to: NSPoint(x: cx - 3, y: cy - 0.5))
                bolt.line(to: NSPoint(x: cx - 0.25, y: cy - 0.5))
                bolt.line(to: NSPoint(x: cx - 1.5, y: cy - h))
                bolt.line(to: NSPoint(x: cx + 3, y: cy + 0.5))
                bolt.line(to: NSPoint(x: cx + 0.25, y: cy + 0.5))
                bolt.close()
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current?.compositingOperation = .destinationOut
                bolt.lineWidth = 2
                bolt.lineJoinStyle = .round
                bolt.stroke()
                NSGraphicsContext.restoreGraphicsState()
                color.setFill()
                bolt.fill()
            }

            if showPercentage {
                value.draw(at: NSPoint(x: iconSize.width + gap, y: (height - valueSize.height) / 2),
                           withAttributes: attributes)
            }
            return true
        }
        image.accessibilityDescription = "\(charge)%"
        image.isTemplate = false
        return image
    }
}
