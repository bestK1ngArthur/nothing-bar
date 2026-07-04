//
//  SettingsDeviceView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftUI

struct SettingsDeviceView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        WithPerceptionTracking {
            Form {
                Section {
                    header
                }

                Section("Settings") {
                    SettingsDeviceToolsView()
                }

                Section("Information") {
                    SettingsDeviceInfoView()
                }
                .disabled(!deviceState.isConnected)
            }
            .formStyle(.grouped)
            .padding(.top, -20)
        }
    }

    @ViewBuilder
    private var header: some View {
        if deviceState.model != nil {
            SettingsDeviceHeaderView()
        } else {
            NoDeviceView()
        }
    }
}
