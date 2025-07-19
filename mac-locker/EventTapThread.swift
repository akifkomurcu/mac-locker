//
//  EventTapThread.swift
//  mac-locker
//
//  Created by KOMURCU on 29.06.2025.
//

import Foundation
import AppKit

class EventTapThread: Thread {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var keepRunning = true

    override func main() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { _, _, _, _ in
                return nil // Klavye olaylarını engelle
            },
            userInfo: nil
        )

        guard let eventTap = eventTap else {
            print("⚠️ Event tap oluşturulamadı.")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        // Run loop'u döngü ile çalıştırıyoruz
        while keepRunning && !isCancelled {
            CFRunLoopRunInMode(.defaultMode, 0.1, true)
        }

        // Temizleme
        CGEvent.tapEnable(tap: eventTap, enable: false)

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            runLoopSource = nil
        }

        CFMachPortInvalidate(eventTap)
        self.eventTap = nil
    }

    func stopSafely() {
        keepRunning = false
    }
}
