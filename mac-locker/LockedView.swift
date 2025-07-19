import SwiftUI

struct LockedView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .edgesIgnoringSafeArea(.all)

            // Kilit kutusu
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.2), radius: 10)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .gray.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(radius: 5)
                }
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)

                Text("LOCKED")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .gray.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 2, y: 2)
                    .tracking(3)
                    .scaleEffect(animate ? 1.02 : 1.0)
                    .opacity(animate ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animate)

                VStack(spacing: 12) {
                    Text("Tap to unlock")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(.white.opacity(0.7))
                                .frame(width: 8, height: 8)
                                .scaleEffect(animate ? 1.3 : 0.8)
                                .animation(
                                    .easeInOut(duration: 1)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: animate
                                )
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(.regularMaterial)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1)
            )
        }
        .onAppear {
            animate = true
        }
    }
}
