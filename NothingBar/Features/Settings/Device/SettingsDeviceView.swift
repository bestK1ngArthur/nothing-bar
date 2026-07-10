//
//  SettingsDeviceView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftNothingEar
import SwiftUI

struct SettingsDeviceView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        WithPerceptionTracking {
            let model = deviceState.model
            let isConnected = deviceState.isConnected
            let supportsGestures = model?.supportsGestures == true

            Form {
                Section {
                    header(model: model)
                }

                Section("Settings") {
                    SettingsDeviceToolsView()
                }

                if supportsGestures {
                    Section("Controls") {
                        SettingsDeviceGesturesView()
                    }
                    .disabled(!isConnected)
                }

                Section("Information") {
                    SettingsDeviceInfoView()
                }
                .disabled(!isConnected)
            }
            .formStyle(.grouped)
            .padding(.top, -20)
        }
    }

    @ViewBuilder
    private func header(model: DeviceModel?) -> some View {
        if model != nil {
            SettingsDeviceHeaderView()
        } else {
            NoDeviceView()
        }
    }
}
