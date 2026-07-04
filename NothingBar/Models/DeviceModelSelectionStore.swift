//
//  DeviceModelSelectionStore.swift
//  NothingBar
//
//  Created by Artem Belkov on 04.07.2026.
//

import Foundation
import SwiftNothingEar

struct DeviceModelSelectionRecord: Codable, Equatable {

    let selectionID: String
    let selectedAt: Date
    let lastDetectedSelectionID: String?
}

final class DeviceModelSelectionStore {

    private enum Keys {
        static let current = "deviceModelSelectionStore"
    }

    private struct Payload: Codable {
        var version: Int
        var records: [String: DeviceModelSelectionRecord]
    }

    private static let currentVersion = 1

    private let defaults: UserDefaults
    private var payload: Payload

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.payload = Self.loadPayload(from: defaults)
    }

    func identity(for deviceInfo: DeviceInfo) -> String? {
        identity(
            bluetoothAddress: deviceInfo.bluetoothAddress,
            serialNumber: deviceInfo.serialNumber
        )
    }

    func identity(bluetoothAddress: String?, serialNumber: String) -> String? {
        if let bluetoothAddress = normalizedIdentityValue(bluetoothAddress) {
            return bluetoothAddress
        }

        return normalizedIdentityValue(serialNumber)
    }

    func selection(for identity: String) -> DeviceModelSelection? {
        guard let selectionID = payload.records[identity]?.selectionID else {
            return nil
        }

        return DeviceModelSelection.selection(for: selectionID)
    }

    func save(selection: DeviceModelSelection, identity: String, detectedModel: DeviceModel?) {
        payload.records[identity] = .init(
            selectionID: selection.id,
            selectedAt: Date(),
            lastDetectedSelectionID: detectedModel.flatMap { DeviceModelSelection.selection(for: $0)?.id }
        )
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(payload) else {
            return
        }

        defaults.set(data, forKey: Keys.current)
    }

    private static func loadPayload(from defaults: UserDefaults) -> Payload {
        if let data = defaults.data(forKey: Keys.current),
           let payload = try? JSONDecoder().decode(Payload.self, from: data),
           payload.version == currentVersion {
            return payload
        }

        return .init(version: currentVersion, records: [:])
    }

    private func normalizedIdentityValue(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "Unknown" else {
            return nil
        }

        return trimmed
    }
}
