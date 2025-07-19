import SwiftUI
import LocalAuthentication

struct PopoverView: View {
    @ObservedObject var blocker: KeyboardBlocker

    var body: some View {
        VStack(spacing: 20) {
            Text("Keyboard Control")
                .font(.headline)
                .foregroundColor(.primary)

            Toggle(isOn: Binding<Bool>(
                get: { blocker.isBlocking },
                set: { newValue in
                    if newValue {
                        blocker.isBlocking = true
                    } else {
                        authenticateWithSystem()
                    }
                }
            )) {
                HStack {
                    Image(systemName: blocker.isBlocking ? "lock.fill" : "lock.open")
                        .foregroundColor(blocker.isBlocking ? .red : .green)
                    Text("Keyboard Lock")
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .padding(.horizontal)

            Spacer(minLength: 10)

            // BURADA ÇIKIŞ BUTONU
            Button {
                NSApp.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top, 12)
        }
        .padding()
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.3), value: blocker.isBlocking)
    }

    func authenticateWithSystem() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Verify your identity to unlock the keyboard.") { success, _ in
                DispatchQueue.main.async {
                    blocker.isBlocking = !success
                }
            }
        } else {
            print("Authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
