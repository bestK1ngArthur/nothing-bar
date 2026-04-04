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
        connectedView
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
    }

    private var connectedView: some View {
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
    }

    private var subtitleView: some View {
        HStack(spacing: 6) {
            if deviceState.isConnected {
                Circle()
                    .fill(.green)
                    .frame(width: 7, height: 7)
            }

            Text(deviceState.isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let battery = deviceState.battery, deviceState.isConnected {
                batterySummaryView(battery)
            }
        }
    }

    @ViewBuilder
    private func batterySummaryView(_ battery: Battery) -> some View {
        switch battery {
            case .budsWithCase(let `case`, let leftBud, let rightBud):
                ViewThatFits(in: .horizontal) {
                    batterySummaryRow(leftBud: leftBud, caseBattery: `case`, rightBud: rightBud, spacing: 8)
                        .font(.subheadline)

                    batterySummaryRow(leftBud: leftBud, caseBattery: `case`, rightBud: rightBud, spacing: 6)
                        .font(.caption)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            batterySummaryItem(title: "L", level: leftBud)
                            batterySummaryItem(title: "C", level: `case`)
                        }

                        HStack(spacing: 8) {
                            batterySummaryItem(title: "R", level: rightBud)
                        }
                    }
                    .font(.caption)
                }
            case .single(let singleBattery):
                batterySummaryItem(title: "Battery", level: singleBattery)
                    .font(.subheadline)
        }
    }

    private func batterySummaryRow(
        leftBud: BatteryLevel,
        caseBattery: BatteryLevel,
        rightBud: BatteryLevel,
        spacing: CGFloat
    ) -> some View {
        HStack(spacing: spacing) {
            batterySummaryItem(title: "L", level: leftBud)
            batterySummaryItem(title: "C", level: caseBattery)
            batterySummaryItem(title: "R", level: rightBud)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private func batterySummaryItem(title: String, level: BatteryLevel) -> some View {
        if level.isConnected {
            HStack(spacing: 4) {
                Text(title)
                    .foregroundColor(.secondary)

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
