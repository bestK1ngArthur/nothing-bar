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
        HStack(spacing: 12) {
            if let deviceImage = deviceState.model?.deviceImage {
                deviceImageWithBattery(deviceImage)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }

            titleView

            Spacer()

            BarSettingsButton()
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func deviceImageWithBattery(_ deviceImage: DeviceModel.DeviceImage) -> some View {
        switch deviceImage {
            case let .buds(left, right):
                VStack(spacing: 8) {
                    // Case battery if available
                    if let battery = deviceState.battery, case .budsWithCase(let caseBattery, _, _) = battery, caseBattery.isConnected {
                        HStack {
                            Spacer()
                            Text("Case: \(caseBattery.level)%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    
                    // Earbud images and their batteries
                    HStack(spacing: 4) {
                        VStack(spacing: 2) {
                            Image(left)
                                .resizable()
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                            
                            if let battery = deviceState.battery {
                                batteryLabel(for: battery, bud: "left")
                            }
                        }
                        
                        VStack(spacing: 2) {
                            Image(right)
                                .resizable()
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                            
                            if let battery = deviceState.battery {
                                batteryLabel(for: battery, bud: "right")
                            }
                        }
                    }
                }
            case let .single(image):
                VStack(spacing: 2) {
                    Image(image)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    
                    if let battery = deviceState.battery {
                        batteryLabel(for: battery, bud: nil)
                    }
                }
        }
    }

    @ViewBuilder
    private func batteryLabel(for battery: Battery, bud: String?) -> some View {
        switch (battery, bud) {
            case (.budsWithCase(_, let leftBud, let rightBud), "left"):
                if leftBud.isConnected {
                    Text("\(leftBud.level)%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            case (.budsWithCase(_, let leftBud, let rightBud), "right"):
                if rightBud.isConnected {
                    Text("\(rightBud.level)%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            case (.single(let singleBattery), nil):
                if singleBattery.isConnected {
                    Text("\(singleBattery.level)%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            default:
                EmptyView()
        }
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(deviceState.model?.displayName ?? "Unknown")
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if !deviceState.isConnected {
                Text("Disconnected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
