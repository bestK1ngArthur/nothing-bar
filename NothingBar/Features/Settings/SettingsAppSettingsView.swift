//
//  SettingsAppSettingsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import ServiceManagement

struct SettingsAppSettingsView: View {

    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
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
