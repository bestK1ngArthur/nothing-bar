//
//  BarHeaderView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar
import AppKit

struct BarHeaderView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        HStack {
            if let imageName = deviceState.model.imageName {
                Image(imageName)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
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
                    switch battery {
                        case .budsWithCase(let `case`, let leftBud, let rightBud):
                            HStack {
                                Text("Case:")
                                batteryView(for: `case`)

                                Spacer()

                                Text("Left:")
                                batteryView(for: leftBud)

                                Spacer()

                                Text("Right:")
                                batteryView(for: rightBud)
                            }

                        case .single(let battery):
                            batteryView(for: battery)
                    }
                }
            }

            Spacer()

            BarSettingsButton()
        }
        .padding(.horizontal, 4)
    }

    private func batteryView(for battery: NothingEar.BatteryLevel) -> some View {
        HStack(spacing: 4) {
            Image(
                systemName: batteryIcon(
                    for: battery.level,
                    isCharging: battery.isCharging
                )
            )
            .font(.caption)
            .foregroundColor(batteryColor(for: battery.level))

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

    private func batteryColor(for level: Int) -> Color {
        switch level {
            case 21...100: return .secondary
            case 11...20: return .orange
            case 1...10: return .red
            default: return .red
        }
    }

}

private extension NothingEar.Model {

    var imageName: String? {
        switch self {
            case .ear1:
                nil
            case .ear2:
                nil
            case .earStick:
                nil
            case .earOpen:
                nil
            case .ear:
                nil
            case .earA:
                nil
            case .headphone1:
                "headphone_1_grey"
            case .cmfBudsPro:
                nil
            case .cmfBuds:
                nil
            case .cmfBudsPro2:
                nil
            case .cmfNeckbandPro:
                nil
        }
    }
}
