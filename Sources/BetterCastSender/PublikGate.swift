import AppKit
import Combine
import SwiftUI

// publik build: Sign in with publik (see PUBLIK-BUILD.md).
//
// Publik.swift holds the gate itself (the screens, the wallet poll and the usage counts).
// This file runs it one time for each launch and draws its screens in the BetterCast window.
// The window shows the gate first. "Welcome to BetterCast" (the permissions wizard) and the
// main window come only after Publik.ensureSignedIn returns.

/// The SwiftUI adapter from publikhq.com/sdk/publik.swift.md: draws the screen as a view and
/// returns the button pressed. When the gate cancels the screen (the wallet poll saw the
/// sign-in), the screen is cleared and nil goes back.
@MainActor final class GateModel: ObservableObject, PublikGateUI {
    @Published var screen: Publik.Screen?
    private var pick: CheckedContinuation<String?, Never>?
    func show(_ s: Publik.Screen) async -> String? {
        await withTaskCancellationHandler { await withCheckedContinuation { c in pick?.resume(returning: nil); screen = s; pick = c } }
        onCancel: { Task { @MainActor in self.press(nil) } }
    }
    func press(_ action: String?) { pick?.resume(returning: action); pick = nil; if action == nil { screen = nil } }
    nonisolated func open(_ url: URL) { Task { @MainActor in NSWorkspace.shared.open(url) } }
}

/// Runs the gate one time for each launch. Every BetterCast window reads `signedIn`.
@MainActor final class PublikGate: ObservableObject {
    static let shared = PublikGate()

    let model = GateModel()
    @Published private(set) var signedIn = false
    private var started = false

    /// Called from BetterCastSenderApp.init, before any window opens. A second call does nothing.
    func start() {
        guard !started else { return }
        started = true
        let ui = model
        Task {
            _ = await Publik.ensureSignedIn(ui)
            signedIn = true
        }
    }

    /// PUBLIK_SELF_TEST=1 (publikhq.com/skills/setup.md, step 6): the module prints
    /// `publik self-test: ok bettercast <version>` after a real GET /wallet and exits.
    /// The app waits here, in BetterCastSenderApp.init, so no window opens.
    nonisolated static func selfTestIfAsked() {
        guard ProcessInfo.processInfo.environment["PUBLIK_SELF_TEST"] != nil else { return }
        let done = DispatchSemaphore(value: 0)
        Task.detached {
            _ = await Publik.ensureSignedIn(TerminalGateUI()) // prints the line and exits
            done.signal()
        }
        done.wait()
        exit(0)
    }
}

/// One gate screen: the title, the body, the note and one button for each action.
struct PublikGateView: View {
    @ObservedObject var model: GateModel

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            if let screen = model.screen {
                Text(verbatim: screen.title)
                    .font(.system(size: 24, weight: .bold))
                Text(verbatim: screen.body)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                if let note = screen.note {
                    Text(verbatim: note)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 10) {
                    ForEach(Array(screen.buttons.enumerated()), id: \.offset) { index, button in
                        if index == 0 {
                            Button { model.press(button.action) } label: { Text(verbatim: button.label).frame(minWidth: 160) }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .keyboardShortcut(.defaultAction)
                        } else {
                            Button { model.press(button.action) } label: { Text(verbatim: button.label) }
                                .controlSize(.large)
                        }
                    }
                }
                .padding(.top, 8)
            } else {
                Text(verbatim: "Sign in with publik")
                    .font(.system(size: 24, weight: .bold))
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(40)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
