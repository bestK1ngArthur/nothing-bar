//
//  SettingsAppSettingsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import ServiceManagement
import SwiftUI

struct SettingsAppSettingsView: View {

    @Environment(AppData.self) private var appData

    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Group {
            SettingsRow(
                title: "Launch at login",
                description: "Automatically start app when you log in to your Mac."
            ) {
                Toggle("", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
            }

            SettingsRow(
                title: "Automatic updates",
                description: "Automatically download and install app updates in the background."
            ) {
                Toggle(
                    "",
                    isOn: .init(
                        get: { appData.appVersion.isAutoUpdateEnabled },
                        set: { appData.appVersion.setAutoUpdateEnabled($0) }
                    )
                )
            }

            SettingsRow(
                title: "Check for updates",
                description: "Current version: \(appData.appVersion.currentVersion)"
            ) {
                Button {
                    Task {
                        await appData.appVersion.checkForUpdatesManually()
                    }
                } label: {
                    if appData.appVersion.isCheckingForUpdates {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Check Now")
                    }
                }
                .disabled(appData.appVersion.isCheckingForUpdates)
            }

            if appData.appVersion.updateAvailable {
                SettingsRow(
                    title: "Update available",
                    description: "A new version is ready to install."
                ) {
                    Button("Install Now") {
                        Task {
                            await appData.appVersion.installUpdate()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear {
            updateLaunchAtLoginState()
        }
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                launchAtLogin = !enabled
            }
        } else {
            launchAtLogin = false
        }
    }

    private func updateLaunchAtLoginState() {
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            launchAtLogin = (status == .enabled)
        } else {
            launchAtLogin = false
        }
    }
}
