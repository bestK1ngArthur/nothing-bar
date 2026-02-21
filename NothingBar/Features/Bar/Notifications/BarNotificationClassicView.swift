//
//  BarNotificationClassicView.swift
//  NothingBar
//
//  Created by Artem Belkov on 21.02.2026.
//

import SwiftNothingEar
import SwiftUI

struct BarNotificationClassicView: View {

    @Environment(AppData.self) private var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        HStack(spacing: 12) {
            if let deviceImage = deviceState.model?.deviceImage {
                DeviceImageView(deviceImage: deviceImage)
                    .frame(height: 32)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let displayName = deviceState.model?.displayName {
                    Text(displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Text(deviceState.isConnected ? "Connected" : "Disconnected")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 200)

            BarNotificationRingView(
                progress: batteryProgress,
                isConnected: deviceState.isConnected,
                size: .medium
            )
        }
        .padding(16)
        .background {
            if #available(macOS 26.0, *) {
                Capsule()
                    .fill(.regularMaterial.opacity(0.3))
                    .glassEffect(.regular)
            } else {
                Capsule()
                    .fill(.regularMaterial)
            }
        }
    }

    private var batteryProgress: Double {
        guard let battery = deviceState.battery else {
            return 0
        }

        switch battery {
            case .single(let status):
                return Double(status.level) / 100.0
            case let .budsWithCase(_, leftBud, rightBud):
                let leftBudLevel = leftBud.isConnected ? leftBud.level : 100
                let rightBudLevel = rightBud.isConnected ? rightBud.level : 100
                return Double(min(leftBudLevel, rightBudLevel)) / 100.0
        }
    }
}
