//
//  WelcomeOverlay.swift
//  mac-locker
//
//  Created by KOMURCU on 12.07.2025.
//

import SwiftUI

struct WelcomeOverlay: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "hand.wave.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.accentColor)
                .padding(.top, 36)

            Text("Welcome!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("""
            TapLocks allows you to temporarily lock your screen whenever you choose. While locked, keyboard input is disabled. You can easily unlock your screen at any time by simply clicking anywhere.
            """)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(nil) // ← Bunu EKLE, ya da varsa kaldır!
                .fixedSize(horizontal: false, vertical: true) // ← Satır sarımı düzgün çalışsın
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)


            Spacer()

            Button(action: { onDismiss() }) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(width: 400, height: 400)
        .background(.thinMaterial)
        .cornerRadius(32)
        .shadow(radius: 36)
        .padding()
        .transition(.scale.combined(with: .opacity))
        .zIndex(10)
    }
}
