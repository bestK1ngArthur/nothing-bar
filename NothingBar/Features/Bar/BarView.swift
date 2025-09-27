//
//  MainView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

struct BarView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    var body: some View {
        Group {
            if let bluetoothError = appData.deviceState.bluetoothError, bluetoothError == .unauthorized {
                BarNoPermissionsView()
            } else if deviceState.isConnected {
                connectedView
            } else {
                BarNoDeviceView()
            }
        }
        .frame(width: 300)
        .cornerRadius(12)
    }
    
    private var connectedView: some View {
        VStack(spacing: 16) {
            BarHeaderView()

            if deviceState.model.supportsANC {
                divider

                BarNoiseCancellationView()
            }
            
            if deviceState.model.supportsSpatialAudio {
                divider
                
                BarSpatialAudioView()
            }

            divider

            BarAudioView()
        }
        .padding(16)
    }
    
    private var divider: some View {
        Divider()
            .opacity(0.3)
    }
}
