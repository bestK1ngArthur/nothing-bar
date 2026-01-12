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
        }
    }
}
