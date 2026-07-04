//
//  NothingBarApp.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import Foundation
import SwiftUI

@main
struct NothingBarApp: App {

    @Environment(\.openWindow) private var openWindow
    @NSApplicationDelegateAdaptor(NothingBarApplicationDelegate.self) private var applicationDelegate

    @State private var appData: AppData
    @State private var statusController: StatusBarController
    @State private var deviceSearchController: DeviceSearchController
    @State private var isSettingsWindowOpen = false
    @State private var isDeviceSetupWindowOpen = false

    init() {
        let appData = AppData()
        let statusController = StatusBarController(appData: appData)
        let deviceSearchController = DeviceSearchController(appData: appData)

        _appData = State(initialValue: appData)
        _statusController = State(initialValue: statusController)
        _deviceSearchController = State(initialValue: deviceSearchController)

        appData.onConnectionStateChanged = { [weak appData, weak statusController, weak deviceSearchController] isConnected in
            guard let appData, let statusController else { return }

            statusController.sync(
                isConnected: isConnected,
                hideWhenDisconnected: appData.hideMenuBarWhenDisconnected
            )
            deviceSearchController?.updateConnectionState(isConnected: isConnected)
        }

        appData.onHideMenuPreferenceChanged = { [weak appData, weak statusController] hideWhenDisconnected in
            guard let appData, let statusController else { return }

            statusController.sync(
                isConnected: appData.deviceState.isConnected,
                hideWhenDisconnected: hideWhenDisconnected
            )
        }

        statusController.sync(
            isConnected: appData.deviceState.isConnected,
            hideWhenDisconnected: appData.hideMenuBarWhenDisconnected
        )

        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    var body: some Scene {
        let _ = configureRuntimeCallbacks()
        Window("Settings", id: "settings") {
            settingsContent
        }
        .windowResizability(.contentSize)

        Window("Device Setup", id: "device-setup") {
            deviceSetupContent
        }
        .windowResizability(.contentSize)
    }

    private var settingsContent: some View {
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

    private var deviceSetupContent: some View {
        DeviceSetupView()
            .environment(appData)
            .onAppear {
                isDeviceSetupWindowOpen = true
                updateDockVisibility()
            }
            .onDisappear {
                isDeviceSetupWindowOpen = false
                updateDockVisibility()
            }
    }

    private func updateDockVisibility() {
        if isSettingsWindowOpen || isDeviceSetupWindowOpen {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    private func configureRuntimeCallbacks() {
        let openWindow = self.openWindow
        let statusController = self.statusController

        if applicationDelegate.onReopenRequested == nil {
            applicationDelegate.onReopenRequested = {
                if statusController.isInserted {
                    statusController.showPopover()
                } else {
                    Self.openSettingsWindow(using: openWindow)
                }
            }
        }

        if appData.onOpenSettingsRequested == nil {
            appData.onOpenSettingsRequested = {
                statusController.closePopover()
                Self.openSettingsWindow(using: openWindow)
            }
        }

        if appData.deviceSetupState.onOpenRequested == nil {
            appData.deviceSetupState.onOpenRequested = {
                statusController.closePopover()
                Self.openDeviceSetupWindow(using: openWindow)
            }

            appData.openPendingDeviceSetupIfNeeded()
        }
    }

    private static func openSettingsWindow(using openWindow: OpenWindowAction) {
        openWindow(id: "settings")

        DispatchQueue.main.async {
            guard let window = NSApp.windows.first(where: { $0.title == "Settings" }) else {
                return
            }

            window.collectionBehavior.insert(.moveToActiveSpace)
            window.makeKeyAndOrderFront(nil)

            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private static func openDeviceSetupWindow(using openWindow: OpenWindowAction) {
        openWindow(id: "device-setup")

        DispatchQueue.main.async {
            guard let window = NSApp.windows.first(where: { $0.title == "Device Setup" }) else {
                return
            }

            window.collectionBehavior.insert(.moveToActiveSpace)
            window.makeKeyAndOrderFront(nil)

            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
