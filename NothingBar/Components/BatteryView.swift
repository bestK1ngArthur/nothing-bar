//
//  BatteryView.swift
//  NothingBar
//
//  Created by Artem Belkov on 27.09.2025.
//

import SwiftNothingEar
import SwiftUI

struct BatteryView: View {

    let battery: NothingEar.Battery

    var body: some View {
        switch battery {
            case .budsWithCase(let `case`, let leftBud, let rightBud):
                HStack(spacing: 4) {
                    Text("C")
                    levelView(for: `case`)
                        .padding(.trailing, 6)

                    Text("L")
                    levelView(for: leftBud)
                        .padding(.trailing, 6)

                    Text("R")
                    levelView(for: rightBud)
                }
                .font(.caption2)

            case .single(let battery):
                levelView(for: battery)
        }
    }

    private func levelView(for battery: NothingEar.BatteryLevel) -> some View {
        HStack(spacing: 4) {
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
