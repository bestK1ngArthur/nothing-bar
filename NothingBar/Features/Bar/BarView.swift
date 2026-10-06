//
//  MainView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftNothingEar
import SwiftUI

struct BarView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        WithPerceptionTracking {
            let bluetoothError = deviceState.bluetoothError
            let model = deviceState.model
            let isConnected = deviceState.isConnected

            Group {
                if bluetoothError == .unauthorized {
                    BarNoPermissionsView()
                } else if let model {
                    deviceView(model: model, isConnected: isConnected)
                } else {
                    noDeviceView
                }
            }
            .frame(width: 320)
            .cornerRadius(12)
        }
    }

    private func deviceView(model: DeviceModel, isConnected: Bool) -> some View {
        VStack(spacing: 16) {
            BarHeaderView()

            if isConnected {
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
