import AppKit
import Foundation

final class DeviceSearchController {

    private let appData: AppData
    private var deviceSearchTimer: Timer?

    init(appData: AppData) {
        self.appData = appData
        setupSystemNotifications()
        updateConnectionState(isConnected: appData.deviceState.isConnected)
    }

    deinit {
        stopDeviceSearchTimer()
        NotificationCenter.default.removeObserver(self)
    }

    func updateConnectionState(isConnected: Bool) {
        if isConnected {
            stopDeviceSearchTimer()
        } else {
            startDeviceSearchTimer()
        }
    }

    private func setupSystemNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWakeNotification),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc
    private func handleWakeNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }

            Task { @MainActor in
                self.appData.nothing.checkAndConnectToExistingDevices()
            }

            if !self.appData.deviceState.isConnected {
                self.startDeviceSearchTimer()
            }
        }
    }

    private func startDeviceSearchTimer() {
        stopDeviceSearchTimer()

        guard !appData.deviceState.isConnected else { return }

        deviceSearchTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.appData.nothing.checkAndConnectToExistingDevices()
            }
        }

        Task { @MainActor in
            appData.nothing.checkAndConnectToExistingDevices()
        }
    }

    private func stopDeviceSearchTimer() {
        deviceSearchTimer?.invalidate()
        deviceSearchTimer = nil
    }
}
