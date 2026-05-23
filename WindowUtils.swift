import Cocoa
import Foundation

func createWindow(x: CGFloat, y: CGFloat, width: CGFloat,
                  height: CGFloat) -> NSWindow {
    // Create the window with titled style
    let window = NSWindow(
        contentRect: NSRect(x: x, y: y, width: width, height: height),
        styleMask: [.titled], // or isKeyWindow can't be true
        backing: .buffered,
        defer: false
    )

    // Set window properties for visibility and focus
    window.isOpaque = true
    window.backgroundColor = NSColor.purple // Set background to purple
    window.titlebarAppearsTransparent = true // Transparent title
    window.level = .screenSaver // High window level for visibility
    window.collectionBehavior = [.canJoinAllSpaces, .stationary]

    // Make window visible, bring it to front, and make it key
    window.makeKeyAndOrderFront(nil)

    return window
}

// Function to show a temporary window with text input focus
func showTemporaryInputWindow(waitTimeMs: Int) {
    // skip
    if waitTimeMs == 0 {
        return
    }
    // Handle wait time and app termination.
    // Default (when no explicit value is passed) is 150ms: empirically the
    // smallest fully-stable value for the CJK race on macOS 26 (Tahoe). Older
    // macOS only needed ~1ms, but defaulting high means existing users don't
    // silently break after an OS upgrade. Pass an explicit smaller value to
    // trade reliability for latency.
    let waitTime = waitTimeMs < 0 ? 150 : waitTimeMs

    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    // Get main screen dimensions to position window in bottom-right
    guard let screen = NSScreen.main else { return }
    let screenRect = screen.visibleFrame

    // Calculate bottom-right position with larger window size
    let windowWidth: CGFloat = 3 // Increased width for visibility
    let windowHeight: CGFloat = 3 // Increased height for visibility
    let xPos = screenRect.maxX - windowWidth - 8 // Margin from right
    let yPos = screenRect.minY + 8 // Margin from bottom

    let _ = createWindow(x: xPos, y: yPos, width: windowWidth,
                         height: windowHeight)

    // Force app to activate and take focus, ignoring other apps
    app.activate(ignoringOtherApps: true)
    let waitTimeSeconds = TimeInterval(waitTime) / 1000.0
    DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeSeconds) {
        // Terminate the application
        app.terminate(nil)
    }
    app.run()
}
