//
//  SettingsDeviceInfoView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI

struct SettingsDeviceInfoView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        InfoRow(title: "Model", value: deviceState.model?.displayName ?? "Unknown")
        InfoRow(title: "Serial number", value: deviceState.serialNumber ?? "Unknown")
        InfoRow(title: "Bluetooth address", value: deviceState.bluetoothAddress ?? "Unknown")
        InfoRow(title: "Firmware version", value: deviceState.firmwareVersion ?? "Unknown")
    }
}

struct InfoRow: View {

    let title: String
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
