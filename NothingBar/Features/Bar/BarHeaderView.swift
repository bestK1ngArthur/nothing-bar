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
                deviceImageView(deviceImage)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }

            titleView

            BarSettingsButton()
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func deviceImageView(_ deviceImage: DeviceModel.DeviceImage) -> some View {
        switch deviceImage {
            case let .buds(left, right):
                HStack(spacing: 2) {
                    Image(left)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 26)

                    Image(right)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 26)
                }
                .frame(minWidth: 32)
            case let .single(image):
                Image(image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 26)
                    .frame(minWidth: 32)
        }
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(deviceState.model?.displayName ?? "Unknown")
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if deviceState.isConnected, let battery = deviceState.battery {
                batterySummaryView(battery)
            } else if !deviceState.isConnected {
                Text("Disconnected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func batterySummaryView(_ battery: Battery) -> some View {
        switch battery {
            case .budsWithCase(let `case`, let leftBud, let rightBud):
                batterySummaryRow(leftBud: leftBud, caseBattery: `case`, rightBud: rightBud)
                    .font(.caption2)
            case .single(let singleBattery):
                batterySummaryItem(title: nil, level: singleBattery)
                    .font(.caption2)
        }
    }

    private func batterySummaryRow(
        leftBud: BatteryLevel,
        caseBattery: BatteryLevel,
        rightBud: BatteryLevel
    ) -> some View {
        HStack(spacing: 5) {
            batterySummaryItem(title: "L", level: leftBud)
            batterySummaryItem(title: "C", level: caseBattery)
            batterySummaryItem(title: "R", level: rightBud)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private func batterySummaryItem(title: String?, level: BatteryLevel) -> some View {
        if level.isConnected {
            HStack(spacing: 2) {
                if let title {
                    Text(title)
                        .foregroundColor(.secondary)
                }

                Image(systemName: batteryIcon(for: level.level, isCharging: level.isCharging))
                    .foregroundColor(batteryColor(for: level.level, isCharging: level.isCharging))

                Text("\(level.level)%")
                    .foregroundColor(.secondary)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    private func batteryIcon(for level: Int, isCharging: Bool) -> String {
        guard !isCharging else {
            return "battery.100.bolt"
        }

        switch level {
            case 81...100: return "battery.100"
            case 61...80: return "battery.75"
            case 41...60: return "battery.50"
            case 21...40: return "battery.25"
            default: return "battery.0"
        }
    }

    private func batteryColor(for level: Int, isCharging: Bool) -> Color {
        guard !isCharging else {
            return .secondary
        }

        return level <= 20 ? .red : .secondary
    }
}
