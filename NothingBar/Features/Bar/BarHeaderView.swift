//
//  BarHeaderView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import SwiftNothingEar
import SwiftUI

struct BarHeaderView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        HStack(spacing: 8) {
            if let deviceImage = deviceState.model?.deviceImage {
                DeviceImageView(deviceImage: deviceImage)
                    .frame(height: 32)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }

            titleView

            Spacer()

            BarSettingsButton()
        }
        .padding(.horizontal, 4)
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(deviceState.model?.displayName ?? "Unknown")
                .font(.headline)
                .foregroundColor(.primary)

            if deviceState.isConnected {
                if let battery = deviceState.battery {
                    BatteryView(battery: battery)
                }
            } else {
                Text("Disconnected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
