//
//  SettingsDeviceHeaderView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

struct SettingsDeviceHeaderView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        VStack(spacing: 16) {
            if let deviceImage = deviceState.model?.deviceImage {
                DeviceImageView(deviceImage: deviceImage)
                    .frame(height: 64)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 8) {
                Text(deviceState.model?.displayName ?? "Unknown")
                    .font(.title)
                    .fontWeight(.semibold)

                subtitleView
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 16)
    }

    private var subtitleView: some View {
        HStack(spacing: 6) {
            Text(deviceState.isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let battery = deviceState.battery, deviceState.isConnected {
                BatteryView(battery: battery)
            }
        }
    }
}
