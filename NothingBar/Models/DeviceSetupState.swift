//
//  DeviceSetupState.swift
//  NothingBar
//
//  Created by Artem Belkov on 04.07.2026.
//

import Perception
import SwiftNothingEar

@Perceptible
final class DeviceSetupState {

    var context: DeviceSetupContext?

    @PerceptionIgnored
    var onOpenRequested: (() -> Void)?

    @PerceptionIgnored
    private var shouldOpenWhenReady = false

    @MainActor
    func present(identity: String, detectedModel: DeviceModel, mode: DeviceSetupMode) {
        context = .init(identity: identity, detectedModel: detectedModel, mode: mode)

        guard let onOpenRequested else {
            shouldOpenWhenReady = true
            return
        }

        onOpenRequested()
    }

    @MainActor
    func cancel() {
        context = nil
    }

    @MainActor
    func openPendingIfNeeded() {
        guard shouldOpenWhenReady else { return }

        shouldOpenWhenReady = false
        onOpenRequested?()
    }
}
