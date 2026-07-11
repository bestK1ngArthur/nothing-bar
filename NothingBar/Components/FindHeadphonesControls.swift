//
//  FindHeadphonesControls.swift
//  NothingBar
//

import SwiftNothingEar
import SwiftUI

struct FindHeadphonesControls: View {

    let ringBuds: RingBuds
    let isConnected: Bool
    let onSetRingBuds: (RingBuds) -> Void

    @State private var showRingBudsAlert = false
    @State private var pendingRingBuds: RingBuds?

    var body: some View {
        ringButtons(current: ringBuds)
            .disabled(!isConnected)
            .alert(isPresented: $showRingBudsAlert) {
                Alert(
                    title: Text("Volume Warning"),
                    message: Text("Your headphones may be in use. Be sure to remove them from your ears before you continue.\n\nA loud sound will be played which could be uncomfortable for anyone who is wearing them."),
                    primaryButton: .default(Text("Play")) {
                        if let pendingRingBuds {
                            onSetRingBuds(pendingRingBuds)
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
    }

    @ViewBuilder
    private func ringButtons(current: RingBuds) -> some View {
        switch current.bud {
            case .left:
                HStack(spacing: 6) {
                    ringButton(current)
                    ringButton(.init(isOn: false, bud: .right))
                        .disabled(current.isOn)
                }
            case .right:
                HStack(spacing: 6) {
                    ringButton(.init(isOn: false, bud: .left))
                        .disabled(current.isOn)
                    ringButton(current)
                }
            case .unibody:
                ringButton(current)
        }
    }

    @ViewBuilder
    private func ringButton(_ value: RingBuds) -> some View {
        let systemImage = value.isOn ? "stop.fill" : "play.fill"
        Button(value.title, systemImage: systemImage) {
            if value.isOn {
                onSetRingBuds(.init(isOn: false, bud: value.bud))
            } else {
                pendingRingBuds = .init(isOn: true, bud: value.bud)
                showRingBudsAlert = true
            }
        }
    }
}

private extension RingBuds {

    var title: String {
        let prefix = isOn ? "Stop" : "Play"
        let suffix = switch bud {
            case .left: " Left"
            case .right: " Right"
            case .unibody: ""
        }
        return "\(prefix)\(suffix)"
    }
}