import SwiftUI
import UIKit

/// App delegate that lets specific screens pin the interface orientation.
/// The whole app is portrait by default; the story player flips to landscape
/// while it's on screen, then restores portrait on the way out.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// The orientations currently allowed. Defaults to portrait.
    static var orientationLock: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }
}

/// Pins the interface to `orientation` while the view is visible and actively
/// rotates the window to match; restores portrait when the view disappears.
private struct LockOrientation: ViewModifier {
    let orientation: UIInterfaceOrientationMask

    func body(content: Content) -> some View {
        content
            .onAppear { apply(orientation) }
            .onDisappear { apply(.portrait) }
    }

    private func apply(_ mask: UIInterfaceOrientationMask) {
        AppDelegate.orientationLock = mask
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
    }
}

extension View {
    /// Lock this screen to the given orientation (restored to portrait on exit).
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        modifier(LockOrientation(orientation: orientation))
    }
}
