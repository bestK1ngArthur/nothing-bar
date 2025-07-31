//
//  NothingBarApp.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar
import AppKit

@main
struct NothingBarApp: App {

    @State private var appData = AppData()

    @State private var isSettingsWindowOpen = false
    @State private var settingsWindowDelegate: SettingsWindowDelegate?

    var body: some Scene {
        MenuBarExtra("Nothing Headphones", systemImage: barImage) {
            BarView()
                .environment(appData)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(appData)
                .onAppear {
                    isSettingsWindowOpen = true
                    updateDockVisibility()

                    NSApp.activate(ignoringOtherApps: true)
                    if let settingsWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                        settingsWindow.makeKeyAndOrderFront(nil)
                        settingsWindow.orderFrontRegardless()
                        settingsWindowDelegate = SettingsWindowDelegate {
                            isSettingsWindowOpen = false
                            updateDockVisibility()
                        }
                        settingsWindow.delegate = settingsWindowDelegate
                    }
                }
                .onDisappear {
                    isSettingsWindowOpen = false
                    updateDockVisibility()
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowBackgroundDragBehavior(.enabled)
    }

    private var barImage: String {
        appData.deviceState.isConnected ? "headphones" : "headphones.slash"
    }

    private func updateDockVisibility() {
        if isSettingsWindowOpen {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

private class SettingsWindowDelegate: NSObject, NSWindowDelegate {

    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
