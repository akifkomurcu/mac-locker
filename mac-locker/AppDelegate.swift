//
//  AppDelegate.swift
//  mac-locker
//
//  Created by KOMURCU on 29.06.2025.
//

import Cocoa
import SwiftUI
import LocalAuthentication

class AppDelegate: NSObject, NSApplicationDelegate, KeyboardBlockerDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover!
    var keyboardBlocker = KeyboardBlocker()
    var lockedWindow: LockedWindow?
    var lockedWindows: [NSWindow] = []
    var isAuthenticating = false
    var welcomeWindow: NSWindow?

    func showLockedWindows() {
        DispatchQueue.main.async {
            // Önce eski pencereleri kapat
            self.lockedWindows.forEach { $0.orderOut(nil) }
            self.lockedWindows.removeAll()

            // Popover açıksa floating, kapalıysa statusBar seviyesi kullan
            let _: NSWindow.Level = (self.popover?.isShown == true) ? .floating : .statusBar

            for screen in NSScreen.screens {
                let window = LockedWindow()
                window.setFrame(screen.frame, display: true)
                window.level = .statusBar + 1
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.isOpaque = false
                window.backgroundColor = .clear
                window.ignoresMouseEvents = false
                window.makeKeyAndOrderFront(nil)

                let hostingView = NSHostingView(rootView: LockedView())
                hostingView.frame = screen.frame
                window.contentView = hostingView

                self.lockedWindows.append(window)
            }

        }
    }

    func hideLockedWindows() {
        DispatchQueue.main.async {
            self.lockedWindows.forEach { $0.orderOut(nil) }
            self.lockedWindows.removeAll()
        }
    }

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "lock.open.fill", accessibilityDescription: "Keyboard Lock")
            button.action = #selector(togglePopover(_:))
        }

        keyboardBlocker.delegate = self

        popover = NSPopover()
        popover.contentSize = NSSize(width: 200, height: 100)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PopoverView(blocker: keyboardBlocker))
        popover.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(lockedWindowClicked), name: .lockedWindowClicked, object: nil)
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            // Sadece kilitliyken ve authentication açık değilken focus geri al!
            if self.keyboardBlocker.isBlocking && !self.isAuthenticating {
                DispatchQueue.main.async {
                    NSApp.activate(ignoringOtherApps: true)
                    self.lockedWindows.forEach { $0.makeKeyAndOrderFront(nil) }
                }
            }
        }
        UserDefaults.standard.removeObject(forKey: "welcomeWindow")
        if !UserDefaults.standard.bool(forKey: "welcomeWindow") {
            showWelcomePopup()
        }
        
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        let settingsMenuItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings(_:)),
            keyEquivalent: ","
        )
        settingsMenuItem.target = self
        appMenu.addItem(settingsMenuItem)

    }
    
    @objc func openSettings(_ sender: Any?) {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.isReleasedWhenClosed = false
        settingsWindow.center()
        settingsWindow.contentView = NSHostingView(rootView: SettingsView())
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    
    func showWelcomePopup() {
        let popupView = NSHostingView(rootView:
            WelcomeOverlay { [weak self] in
                UserDefaults.standard.set(true, forKey: "welcomeWindow")
                self?.welcomeWindow?.close()
                self?.welcomeWindow = nil
            }
        )
        popupView.frame = NSRect(x: 0, y: 0, width: 420, height: 420)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.contentView = popupView
        window.center()
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window.orderFrontRegardless()
        self.welcomeWindow = window
    }




    func keyboardBlockerDidChangeState(isBlocking: Bool) {
        DispatchQueue.main.async {
            let iconName = isBlocking ? "lock.fill" : "lock.open.fill"
            self.statusItem?.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Keyboard Lock")

            if isBlocking {
                self.showLockedWindows()
            } else {
                self.hideLockedWindows()
            }
        }
    }

    func showLockedWindow() {
        DispatchQueue.main.async {
            if self.lockedWindow == nil {
                let lockedView = LockedView()
                _ = NSHostingView(rootView: lockedView)
                self.lockedWindow = LockedWindow()

                self.lockedWindow?.makeKeyAndOrderFront(nil)
                self.lockedWindow?.level = .statusBar
            }
        }
    }
    func hideLockedWindow() {
        DispatchQueue.main.async {
            if let window = self.lockedWindow {
                window.orderOut(nil)
                self.lockedWindow = nil // serbest bırak, tekrar çağrılmayacak
            }
        }
    }

    @objc func lockedWindowClicked() {
        DispatchQueue.main.async {
            self.showAuthenticationModal()
        }
    }

    // macOS kimlik doğrulama modalini açan fonksiyon
    func showAuthenticationModal() {
        isAuthenticating = true
        let context = LAContext()
        var error: NSError?
        let reason = "Verify your identity to open the lock screen."

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    self.isAuthenticating = false
                    if success {
                        self.hideLockedWindows()
                        self.keyboardBlocker.isBlocking = false
                    }
                }
            }
        } else {
        isAuthenticating = false
    }
    }

    @objc func togglePopover(_ sender: Any?) {
        DispatchQueue.main.async {
            if let button = self.statusItem?.button {
                if self.popover.isShown {
                    self.popover.performClose(sender)
                } else {
                    self.lockedWindows.forEach {
                        $0.level = .floating
                        $0.ignoresMouseEvents = true // <<< BURASI
                    }
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }

    func popoverDidClose(_ notification: Notification) {
        if keyboardBlocker.isBlocking {
            self.lockedWindows.forEach {
                $0.level = .statusBar
                $0.ignoresMouseEvents = false // <<< GERİ AL
            }
        }
    }

}
