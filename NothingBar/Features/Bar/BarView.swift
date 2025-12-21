//
//  MainView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

struct BarView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        Group {
            if let bluetoothError = appData.deviceState.bluetoothError, bluetoothError == .unauthorized {
                BarNoPermissionsView()
            } else if let model = deviceState.model {
                deviceView(model: model)
            } else {
                BarNoDeviceView()
            }
        }
        .frame(width: 320)
        .cornerRadius(12)
    }

    private func deviceView(model: Model) -> some View {
        VStack(spacing: 16) {
            BarHeaderView()

            if deviceState.isConnected {
                connectedView(model: model)
            }
        }
        .padding(16)
    }

    private func connectedView(model: Model) -> some View {
        VStack(spacing: 16) {
            if model.supportsANC {
                divider

                BarNoiseCancellationView()
            }

            if model.supportsSpatialAudio {
                divider

                BarSpatialAudioView()
            }

            divider

            BarAudioView()
        }
    }

    private var divider: some View {
        Divider()
            .opacity(0.3)
    }
}
