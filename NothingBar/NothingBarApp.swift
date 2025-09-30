//
//  NothingBarApp.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import Foundation
import SwiftNothingEar
import SwiftUI

@main
struct NothingBarApp: App {

    @State private var appData = AppData()

    @State private var isSettingsWindowOpen = false
    @State private var settingsWindowDelegate: SettingsWindowDelegate?
    @State private var deviceSearchTimer: Timer?

    init() {
        setupSystemNotifications()
    }

    var body: some Scene {
        MenuBarExtra("Nothing Headphones", systemImage: barImage) {
            BarView()
                .environment(appData)
                .task {
                    startDeviceSearchTimer()
                }
        }
        .menuBarExtraStyle(.window)
        .onChange(of: appData.deviceState.isConnected) { _, isConnected in
            if isConnected {
                stopDeviceSearchTimer()
            } else {
                startDeviceSearchTimer()
            }
        }

        Window("Settings", id: "settings") {
            SettingsView()
                .environment(appData)
                .onAppear {
                    isSettingsWindowOpen = true
                    updateDockVisibility()
                }
                .onDisappear {
                    isSettingsWindowOpen = false
                    updateDockVisibility()
                }
        }
        .defaultLaunchBehavior(.suppressed)
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

    private func setupSystemNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Task { @MainActor in
                    appData.nothing.checkAndConnectToExistingDevices()
                }

                if !appData.deviceState.isConnected {
                    startDeviceSearchTimer()
                }
            }
        }
    }

    private func startDeviceSearchTimer() {
        stopDeviceSearchTimer()

        guard !appData.deviceState.isConnected else { return }

        deviceSearchTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [self] _ in
            Task { @MainActor in
                appData.nothing.checkAndConnectToExistingDevices()
            }
        }

        Task { @MainActor in
            appData.nothing.checkAndConnectToExistingDevices()
        }
    }

    private func stopDeviceSearchTimer() {
        deviceSearchTimer?.invalidate()
        deviceSearchTimer = nil
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
