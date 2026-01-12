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

    private func deviceView(model: DeviceModel) -> some View {
        VStack(spacing: 16) {
            BarHeaderView()

            if deviceState.isConnected {
                connectedView(model: model)
            }
        }
        .padding(16)
    }

    private func connectedView(model: DeviceModel) -> some View {
        VStack(spacing: 16) {
            if model.supportsNoiseCancellation {
                Divider()

                BarNoiseCancellationView()
            }

            if model.supportsSpatialAudio {
                Divider()

                BarSpatialAudioView()
            }

            Divider()

            BarAudioView()
        }
    }

    private var noDeviceView: some View {
        NoDeviceView()
            .overlay(alignment: .topTrailing) {
                BarSettingsButton()
            }
            .padding(16)
    }
}
