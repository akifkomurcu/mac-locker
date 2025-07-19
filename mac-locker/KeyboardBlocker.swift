//
//  KeyboardBlocker.swift
//  mac-locker
//
//  Created by KOMURCU on 29.06.2025.
//

import Foundation
import AppKit

protocol KeyboardBlockerDelegate: AnyObject {
    func keyboardBlockerDidChangeState(isBlocking: Bool)
}

class KeyboardBlocker: ObservableObject {
    weak var delegate: KeyboardBlockerDelegate?

    @Published var isBlocking = false {
        didSet {
            if isBlocking {
                startBlocking()
            } else {
                stopBlocking()
            }
            delegate?.keyboardBlockerDidChangeState(isBlocking: isBlocking)
        }
    }

    private var eventTapThread: EventTapThread?

    func startBlocking() {
        guard eventTapThread == nil else { return }

        let thread = EventTapThread()
        eventTapThread = thread
        thread.start()
    }

    func stopBlocking() {
        guard let thread = eventTapThread else { return }

        thread.stopSafely() // döngü durur

        // Thread'in gerçekten durmasını bekle
        while thread.isExecuting {
            Thread.sleep(forTimeInterval: 0.05)
        }

        thread.cancel() // işaretle
        eventTapThread = nil
    }
}

