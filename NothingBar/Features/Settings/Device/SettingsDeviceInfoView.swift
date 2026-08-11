//
//  SettingsDeviceInfoView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftUI

struct SettingsDeviceInfoView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var unknown: String {
        String(localized: "Unknown", comment: "Fallback value when device info is unavailable")
    }

    var body: some View {
        WithPerceptionTracking {
            Group {
                InfoRow(title: "Model", value: deviceState.model?.displayName ?? unknown)
                InfoRow(title: "Serial number", value: deviceState.serialNumber ?? unknown)
                InfoRow(title: "Bluetooth address", value: deviceState.bluetoothAddress ?? unknown)
                InfoRow(title: "Firmware version", value: deviceState.firmwareVersion ?? unknown)
            }
        }
    }
}

struct InfoRow: View {

    let title: LocalizedStringKey
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
