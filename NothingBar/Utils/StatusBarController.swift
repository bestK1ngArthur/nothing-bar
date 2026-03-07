import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject {

    private let appData: AppData
    private let popover: NSPopover

    private var statusItem: NSStatusItem?

    var isInserted: Bool {
        statusItem != nil
    }

    init(appData: AppData) {
        self.appData = appData
        self.popover = NSPopover()
        super.init()

        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = makeContentViewController()
    }

    func sync(isConnected: Bool, hideWhenDisconnected: Bool) {
        let shouldInsert = !hideWhenDisconnected || isConnected

        guard shouldInsert else {
            closePopover()
            removeStatusItem()
            return
        }

        insertStatusItemIfNeeded()
        updateStatusImage(isConnected: isConnected)
    }

    func showPopover() {
        guard let button = statusItem?.button else { return }

        if popover.isShown {
            return
        }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    func closePopover() {
        popover.performClose(nil)
    }

    @objc
    private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func insertStatusItemIfNeeded() {
        guard statusItem == nil else { return }

        let newStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        newStatusItem.button?.target = self
        newStatusItem.button?.action = #selector(togglePopover(_:))
        newStatusItem.button?.imagePosition = .imageOnly

        statusItem = newStatusItem
    }

    private func removeStatusItem() {
        guard let statusItem else { return }

        NSStatusBar.system.removeStatusItem(statusItem)
        self.statusItem = nil
    }

    private func updateStatusImage(isConnected: Bool) {
        guard let button = statusItem?.button else { return }

        let symbolName = isConnected ? "headphones" : "headphones.slash"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Nothing Headphones")
        image?.isTemplate = true
        button.image = image
    }

    private func makeContentViewController() -> NSViewController {
        NSHostingController(rootView: BarView().environment(appData))
    }
}
