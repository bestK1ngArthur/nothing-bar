//
//  SettingsDeviceGesturesView.swift
//  NothingBar
//

import Perception
import SwiftNothingEar
import SwiftUI

struct SettingsDeviceGesturesView: View {

    @Environment(AppData.self) private var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        WithPerceptionTracking {
            let isConnected = deviceState.isConnected
            let gestures = deviceState.gestures

            Group {
                ForEach(GestureDevice.allCases, id: \.self) { device in
                    SettingsRow(
                        title: "\(device.displayName) controls",
                        description: "Configure touch controls for the \(device.displayName.lowercased()) side"
                    ) {
                        gestureControls(
                            device: device,
                            gestures: gestures,
                            isConnected: isConnected
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func gestureControls(
        device: GestureDevice,
        gestures: [DeviceGesture],
        isConnected: Bool
    ) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            ForEach(GestureType.allCases, id: \.self) { type in
                gestureMenu(
                    device: device,
                    type: type,
                    currentAction: currentAction(
                        device: device,
                        type: type,
                        gestures: gestures
                    ),
                    isConnected: isConnected
                )
            }
        }
    }

    @ViewBuilder
    private func gestureMenu(
        device: GestureDevice,
        type: GestureType,
        currentAction: GestureAction,
        isConnected: Bool
    ) -> some View {
        Menu {
            ForEach(GestureAction.allCases, id: \.self) { action in
                Button {
                    setGesture(device: device, type: type, action: action)
                } label: {
                    Text(action.displayName) + (currentAction == action ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
                }
            }
        } label: {
            Text("\(type.displayName): \(currentAction.displayName)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .disabled(!isConnected)
    }

    private func currentAction(
        device: GestureDevice,
        type: GestureType,
        gestures: [DeviceGesture]
    ) -> GestureAction {
        gestures.first { $0.device == device && $0.type == type }?.action ?? .none
    }

    private func setGesture(
        device: GestureDevice,
        type: GestureType,
        action: GestureAction
    ) {
        var updatedGestures = deviceState.gestures.filter { !($0.device == device && $0.type == type) }
        updatedGestures.append(DeviceGesture(device: device, type: type, action: action))
        deviceState.gestures = updatedGestures
        nothing.setGesture(type: type, action: action, device: device)
        AppLogger.settings.uiSettingChanged("Gesture \(device.displayName) \(type.displayName)", value: action.displayName)
    }
}