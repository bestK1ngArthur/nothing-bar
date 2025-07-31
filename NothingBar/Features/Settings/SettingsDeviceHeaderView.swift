//
//  SettingsDeviceHeaderView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar

struct SettingsDeviceHeaderView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        VStack(spacing: 16) {
            if let imageName = deviceState.model.imageName {
                Image(imageName)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 8) {
                Text(deviceState.model.displayName)
                    .font(.title)
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Circle()
                        .fill(deviceState.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)

                    Text(deviceState.isConnected ? "Connected" : "Disconnected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 16)
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
