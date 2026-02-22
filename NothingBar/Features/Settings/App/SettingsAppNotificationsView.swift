//
//  SettingsAppNotificationsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 08.11.2025.
//

import SwiftUI

struct SettingsAppNotificationsView: View {

    @Environment(AppData.self) private var appData

    @AppStorage("showNotifications") private var showConnectNotifications = true
    @AppStorage("showBatteryNotifications") private var showBatteryNotifications = true
    @AppStorage("notificationStyle") private var notificationStyleRawValue = NotificationStyle.defaultValue.rawValue

    var body: some View {
        Group {
            SettingsRow(
                title: "Connection status",
                description: "Show connect and disconnect notifications"
            ) {
                Toggle("", isOn: $showConnectNotifications)
                    .onChange(of: showConnectNotifications) { _, newValue in
                        appData.showConnectNotifications = newValue
                    }
            }

            SettingsRow(
                title: "Battery level",
                description: "Show 20% / 10% / 5% level notifications"
            ) {
                Toggle("", isOn: $showBatteryNotifications)
                    .onChange(of: showBatteryNotifications) { _, newValue in
                        appData.showBatteryNotifications = newValue
                    }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Notification style")
                    .font(.body)

                Text("Choose where and how notifications are shown")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 10) {
                    styleCard(.classic)
                    styleCard(.apple)
                }
            }
        }
        .onAppear {
            appData.showConnectNotifications = showConnectNotifications
            appData.showBatteryNotifications = showBatteryNotifications
            appData.notificationStyle = NotificationStyle(rawValue: notificationStyleRawValue) ?? .defaultValue
        }
    }

    private var selectedStyle: NotificationStyle {
        NotificationStyle(rawValue: notificationStyleRawValue) ?? .defaultValue
    }

    private func styleCard(_ style: NotificationStyle) -> some View {
        NotificationStyleCard(
            style: style,
            isSelected: selectedStyle == style
        ) {
            notificationStyleRawValue = style.rawValue
            appData.notificationStyle = style
        }
    }
}
