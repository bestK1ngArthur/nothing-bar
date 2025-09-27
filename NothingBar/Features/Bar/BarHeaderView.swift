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
        HStack {
            if let deviceImage = deviceState.model.deviceImage {
                DeviceImageView(deviceImage: deviceImage)
                    .frame(height: 32)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(deviceState.model.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Circle()
                        .fill(deviceState.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                }

                if let battery = deviceState.battery {
                    BatteryView(battery: battery)
                }
            }

            Spacer()

            BarSettingsButton()
        }
        .padding(.horizontal, 4)
    }
}
