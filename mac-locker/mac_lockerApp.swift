//
//  mac_lockerApp.swift
//  mac-locker
//
//  Created by KOMURCU on 19.07.2025.
//

import SwiftUI

@main
struct MacLockAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // Ayarlar penceresi yerine hiçbir pencere açılmasın
        }
    }
}
