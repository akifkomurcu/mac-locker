import Cocoa
import SwiftUI

class LockedWindow: NSWindow {
    // Varsayılan init
    override init(contentRect: NSRect = .zero,
                  styleMask: NSWindow.StyleMask = [.borderless],
                  backing: NSWindow.BackingStoreType = .buffered,
                  defer flag: Bool = false) {
        super.init(contentRect: contentRect, styleMask: styleMask, backing: backing, defer: flag)

        let screenSize = NSScreen.main?.frame ?? .zero
        self.setFrame(screenSize, display: true)

        self.isOpaque = false
        self.backgroundColor = NSColor.black.withAlphaComponent(0.6)
        self.level = .statusBar + 1 // Menü çubuğundan üstte
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.makeKeyAndOrderFront(nil)
    }

    convenience init(contentView: NSView) {
        self.init(contentRect: .zero)
        self.contentView = contentView
    }

    convenience init() {
        self.init(contentRect: .zero)
    }

    override var canBecomeKey: Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // Tıklanınca Notification gönder
        NotificationCenter.default.post(name: .lockedWindowClicked, object: nil)
    }
}

extension Notification.Name {
    static let lockedWindowClicked = Notification.Name("lockedWindowClicked")
}
