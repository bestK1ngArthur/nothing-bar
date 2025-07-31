//
//  SettingsDeviceView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI

struct SettingsDeviceView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        Form {
            Section {
                SettingsDeviceHeaderView()
            }

            Section("Settings") {
                SettingsDeviceToolsView()
            }

            Section("Information") {
                SettingsDeviceInfoView()
            }
        }
        .formStyle(.grouped)
        .padding(.top, -20)
    }
}
