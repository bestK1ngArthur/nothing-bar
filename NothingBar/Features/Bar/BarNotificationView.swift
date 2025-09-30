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
        VStack(spacing: 2) {
            if let displayName = deviceState.model?.displayName {
                Text(displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text(deviceState.isConnected ? "Connected" : "Disconnected")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, iconSize + 16)
        .overlay(alignment: .leading) {
            if let deviceImage = deviceState.model?.deviceImage {
                DeviceImageView(deviceImage: deviceImage)
                    .frame(height: iconSize)
            }
        }
        .overlay(alignment: .trailing) {
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

    private func batteryView(battery: NothingEar.Battery) -> some View {
        switch battery {
            case .single(let status):
                ringView(progress: Double(status.level) / 100.0)
            case let .budsWithCase(_, leftBud, rightBud):
                ringView(progress: Double(min(leftBud.level, rightBud.level)) / 100.0)
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
