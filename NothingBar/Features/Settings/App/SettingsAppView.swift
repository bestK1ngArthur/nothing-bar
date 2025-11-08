//
//  SettingsAppView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI

struct SettingsAppView: View {

    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Section {
                header
            }

            Section("Notifications") {
                SettingsAppNotificationsView()
            }

            Section("App") {
                SettingsAppSettingsView()
            }

            Section("About") {
                SettingsAppInfoView()
            }
        }
        .formStyle(.grouped)
        .padding(.top, -20)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Image(.appIcon)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)

            VStack(spacing: 8) {
                Text("NothingBar")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Control your headphones from macOS bar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 20)
    }
}
