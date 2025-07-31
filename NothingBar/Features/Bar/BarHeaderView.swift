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
    @Environment(\.openSettings) private var openSettings

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

            Button {
                openFocusedSettings()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .buttonStyle(HoverButtonStyle())
            .help("Settings")
            .contextMenu {
                Button {
                    openFocusedSettings()
                } label: {
                    Text("Open Settings")
                    Image(systemName: "gearshape.fill")
                }

                Button(role: .destructive) {
                    quitApp()
                } label: {
                    Text("Quit App")
                    Image(systemName: "xmark.circle.fill")
                }
            }
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

    private func openFocusedSettings() {
        openSettings()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
            if let settingsWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                settingsWindow.makeKeyAndOrderFront(nil)
                settingsWindow.orderFrontRegardless()
            }
        }
    }

    private func quitApp() {
        NSApp.terminate(nil)
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

private struct HoverButtonStyle: ButtonStyle {

    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .background(
                Circle()
                    .fill(backgroundColor(configuration: configuration))
            )
            .onHover { hovering in
                isHovering = hovering
            }
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        if configuration.isPressed {
            .secondary.opacity(0.4)
        } else if isHovering {
            .secondary.opacity(0.2)
        } else {
            .clear
        }
    }
}
