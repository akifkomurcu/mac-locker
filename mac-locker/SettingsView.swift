//
//  SettingsView.swift
//  mac-locker
//
//  Created by KOMURCU on 25.07.2025.
//
import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("There are currently no configurable settings.")
                .font(.title3)
            Text("This app works out of the box.")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}
