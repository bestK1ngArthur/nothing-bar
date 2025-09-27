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
            // Launch at Login Setting
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Launch at login")
                        .font(.body)
                    Text("Automatically start app when you log in to your Mac.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Toggle("", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
            }

            // Auto Update Setting
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Automatic updates")
                        .font(.body)
                    Text("Automatically download and install app updates in the background.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { appData.appVersion.isAutoUpdateEnabled },
                    set: { appData.appVersion.setAutoUpdateEnabled($0) }
                ))
            }

            // Manual Update Check
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check for updates")
                        .font(.body)
                    Text("Current version: \(appData.appVersion.currentVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Button(action: {
                    Task {
                        await appData.appVersion.checkForUpdatesManually()
                    }
                }) {
                    if appData.appVersion.isCheckingForUpdates {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Check Now")
                    }
                }
                .disabled(appData.appVersion.isCheckingForUpdates)
            }

            // Update Available Indicator
            if appData.appVersion.updateAvailable {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Update available")
                            .font(.body)
                            .foregroundColor(.green)
                        Text("A new version is ready to install.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

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
