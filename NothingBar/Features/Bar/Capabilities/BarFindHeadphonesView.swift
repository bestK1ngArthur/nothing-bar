//
//  BarFindHeadphonesView.swift
//  NothingBar
//

import Perception
import SwiftNothingEar
import SwiftUI

struct BarFindHeadphonesView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        WithPerceptionTracking {
            let isConnected = deviceState.isConnected
            let ringBuds = deviceState.ringBuds ?? defaultRingBuds

            BarSectionView(
                title: "Find Headphones",
                value: ringBuds.isOn ? "Playing" : nil
            ) {
                FindHeadphonesControls(
                    ringBuds: ringBuds,
                    isConnected: isConnected
                ) { ringBuds in
                    deviceState.ringBuds = ringBuds
                    nothing.setRingBuds(ringBuds)
                    AppLogger.audio.uiSettingChanged("Find Headphones", value: ringBuds.isOn)
                }
            }
        }
    }

    private var defaultRingBuds: RingBuds {
        switch deviceState.battery {
            case .budsWithCase:
                .init(isOn: false, bud: .left)
            default:
                .init(isOn: false, bud: .unibody)
        }
    }
}