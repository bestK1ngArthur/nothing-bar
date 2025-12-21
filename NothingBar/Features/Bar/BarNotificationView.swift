//
//  BarNotificationView.swift
//  NothingBar
//
//  Created by Artem Belkov on 29.09.2025.
//

import SwiftNothingEar
import SwiftUI

struct BarNotificationView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private let iconSize = 32.0

    var body: some View {
        HStack(spacing: 8) {
            if let deviceImage = deviceState.model?.deviceImage {
                DeviceImageView(deviceImage: deviceImage)
                    .frame(height: iconSize)
            }

            contentView
                .frame(minWidth: 120)

            batteryView(battery: deviceState.battery ?? .single(.disconnected))
                .frame(height: iconSize)
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

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let displayName = deviceState.model?.displayName {
                Text(displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(deviceState.isConnected ? "Connected" : "Disconnected")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func batteryView(battery: Battery) -> some View {
        switch battery {
            case .single(let status):
                ringView(progress: Double(status.level) / 100.0)
            case let .budsWithCase(_, leftBud, rightBud):
                let leftBudLevel = leftBud.isConnected ? leftBud.level : 100
                let rightBudLevel = rightBud.isConnected ? rightBud.level : 100
                ringView(progress: Double(min(leftBudLevel, rightBudLevel)) / 100.0)
        }
    }

    @ViewBuilder
    private func ringView(progress: Double) -> some View {
        let color: Color = if deviceState.isConnected {
            progress > 0.2 ? .green : .red
        } else {
            .secondary
        }

        ZStack {
            if progress > 0 {
                Text("\(Int((progress * 100).rounded()))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
            }

            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.1)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut, value: progress)
        }
    }
}

#Preview {
    let appData = AppData()
    appData.deviceState.model = .headphone1(.grey)
    appData.deviceState.battery = .single(.disconnected)
    return BarNotificationView()
        .environment(appData)
}
