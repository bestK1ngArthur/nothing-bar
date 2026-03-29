//
//  BatteryView.swift
//  NothingBar
//
//  Created by Artem Belkov on 27.09.2025.
//

import SwiftNothingEar
import SwiftUI

struct BatteryView: View {

    let battery: Battery

    var body: some View {
        switch battery {
            case .budsWithCase(let `case`, let leftBud, let rightBud):
                VStack(alignment: .leading, spacing: 3) {
                    if `case`.isConnected {
                        HStack(spacing: 4) {
                            Text("Case")
                                .foregroundColor(.secondary)
                            levelView(for: `case`, isCompact: true)
                        }
                    }

                    if leftBud.isConnected {
                        HStack(spacing: 4) {
                            Text("Left")
                                .foregroundColor(.secondary)
                            levelView(for: leftBud, isCompact: true)
                        }
                    }

                    if rightBud.isConnected {
                        HStack(spacing: 4) {
                            Text("Right")
                                .foregroundColor(.secondary)
                            levelView(for: rightBud, isCompact: true)
                        }
                    }
                }
                .font(.caption2)

            case .single(let battery):
                levelView(for: battery, isCompact: false)
        }
    }

    private func levelView(for battery: BatteryLevel, isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 2 : 4) {
            Image(
                systemName: batteryIcon(
                    for: battery.level,
                    isCharging: battery.isCharging
                )
            )
            .font(.caption)
            .foregroundColor(batteryColor(for: battery.level, isCharging: battery.isCharging))

            Text("\(battery.level)%")
                .font(.caption)
                .foregroundColor(.secondary)
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
            case 1...20: return "battery.0"
            default: return "battery.0"
        }
    }

    private func batteryColor(for level: Int, isCharging: Bool) -> Color {
        guard !isCharging else {
            return .secondary
        }

        switch level {
            case 21...100: return .secondary
            case 0...20: return .red
            default: return .red
        }
    }
}
