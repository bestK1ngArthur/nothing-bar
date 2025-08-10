//
//  MainView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar

struct BarView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        Group {
            if !deviceState.hasBluetoothPermissions {
                BarNoPermissionsView()
            } else if deviceState.isConnected {
                ScrollView {
                    VStack(spacing: 16) {
                        BarHeaderView()

                        if deviceState.model.supportsANC {
                            Divider()
                                .opacity(0.3)

                            BarNoiseCancellationView()
                        }

                        Divider()
                            .opacity(0.3)

                        BarAudioView()
                    }
                    .padding(16)
                }
            } else {
                BarNoDeviceView()
            }
        }
        .frame(width: 300)
        .cornerRadius(12)
        .background(.ultraThinMaterial)
    }
}
