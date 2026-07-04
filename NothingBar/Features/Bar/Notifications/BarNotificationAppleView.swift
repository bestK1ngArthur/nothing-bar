//
//  BarNotificationAppleView.swift
//  NothingBar
//
//  Created by Artem Belkov on 21.02.2026.
//

import Perception
import SwiftNothingEar
import SwiftUI

struct BarNotificationAppleView: View {

    @Environment(AppData.self) private var appData

    private let iconSize = 28.0

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        WithPerceptionTracking {
            let model = deviceState.model
            let isConnected = deviceState.isConnected
            let battery = deviceState.battery

            HStack(spacing: 12) {
                if let deviceImage = model?.deviceImage {
                    DeviceImageView(deviceImage: deviceImage, budsOverlapRatio: 0.15)
                        .frame(width: iconSize, height: iconSize)
                }

                VStack(spacing: 2) {
                    if let displayName = model?.displayName {
                        Text(displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }

                    Text(isConnected ? "Connected" : "Off")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                BarNotificationRingView(
                    progress: batteryProgress(for: battery),
                    isConnected: isConnected,
                    size: .small
                )
            }
            .frame(maxWidth: 300)
            .padding(10)
            .background {
                if #available(macOS 26.0, *) {
                    Capsule()
                        .fill(.regularMaterial.opacity(0.3))
                        .overlay {
                            Capsule()
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        }
                        .glassEffect(.regular)
                } else {
                    Capsule()
                        .fill(.regularMaterial)
                        .overlay {
                            Capsule()
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        }
                }
            }
        }
    }

    private func batteryProgress(for battery: Battery?) -> Double {
        guard let battery else {
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
