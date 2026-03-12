import AppKit
import Foundation

final class NothingBarApplicationDelegate: NSObject, NSApplicationDelegate {

    var onReopenRequested: (() -> Void)?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        onReopenRequested?()
        return false
    }
}
