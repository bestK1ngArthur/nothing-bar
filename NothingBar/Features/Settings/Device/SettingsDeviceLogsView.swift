//
//  SettingsDeviceLogsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 24.01.2026.
//

import AppKit
import OSLog
import SwiftUI

struct SettingsDeviceLogsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DeviceLogsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            logList
        }
        .frame(minWidth: 640, minHeight: 420)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("Device Logs")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            Button("Clear") {
                viewModel.clear()
            }

            Button("Copy All") {
                copyAllLogs()
            }

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
    }

    private var logList: some View {
        List(viewModel.entries) { entry in
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.header)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(entry.message)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contextMenu {
                Button("Copy Log") {
                    copyLog(entry)
                }
            }
        }
        .overlay {
            if viewModel.entries.isEmpty {
                Text("Waiting for device logs...")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func copyLog(_ entry: DeviceLogsViewModel.Entry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("\(entry.header) \(entry.message)", forType: .string)
    }

    private func copyAllLogs() {
        let pasteboard = NSPasteboard.general
        let text = viewModel.entries
            .map { "\($0.header) \($0.message)" }
            .joined(separator: "\n")
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

private final class DeviceLogsViewModel: ObservableObject {

    struct Entry: Identifiable {
        let id = UUID()
        let date: Date
        let category: String
        let level: OSLogEntryLog.Level
        let message: String

        var header: String {
            "[\(Entry.formatter.string(from: date))] \(category) • \(level.displayName)"
        }

        private static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter
        }()
    }

    @Published var entries: [Entry] = []

    private let logQueue = DispatchQueue(label: "com.nothingbar.logs", qos: .utility)
    private let subsystem = "\(Bundle.main.bundleIdentifier ?? "com").NothingEar"
    private let historyWindow: TimeInterval = 120
    private var store: OSLogStore?
    private var position: OSLogPosition?
    private var lastEntryDate: Date?
    private var lastEntryMessage: String?
    private var timer: Timer?
    private var sessionStart: Date?
    private var pendingEntries: [Entry] = []
    private var lastFlushDate: Date = .distantPast
    private var isActive: Bool = true
    private var activeObservers: [NSObjectProtocol] = []

    func start() {
        guard timer == nil else { return }

        do {
            store = try OSLogStore(scope: .currentProcessIdentifier)
            position = store?.position(timeIntervalSinceLatestBoot: 0)
            lastEntryDate = nil
            lastEntryMessage = nil
            sessionStart = Date()
            pendingEntries.removeAll()
            lastFlushDate = .distantPast
            isActive = NSApp.isActive
            observeAppActivity()
        } catch {
            entries = [
                Entry(
                    date: Date(),
                    category: "system",
                    level: .error,
                    message: "Failed to open log store: \(error.localizedDescription)"
                )
            ]
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        removeActivityObservers()
    }

    func clear() {
        entries.removeAll()
        lastEntryDate = nil
        lastEntryMessage = nil
        sessionStart = Date()
        pendingEntries.removeAll()
    }

    private func poll() {
        logQueue.async { [weak self] in
            guard let self, self.isActive, let store = self.store, let position = self.position else { return }

            do {
                let predicate = NSPredicate(format: "subsystem == %@", self.subsystem)
                let sequence = try store.getEntries(at: position, matching: predicate)

                var newEntries: [Entry] = []
                var latestDate: Date?
                let now = Date()
                let sessionStart = self.sessionStart ?? now
                let cutoff = now.addingTimeInterval(-self.historyWindow)

                for case let logEntry as OSLogEntryLog in sequence {
                    let isWithinWindow = logEntry.date >= cutoff
                    let isDuringSession = logEntry.date >= sessionStart
                    guard isWithinWindow || isDuringSession else { continue }

                    if let lastEntryDate = self.lastEntryDate {
                        if logEntry.date < lastEntryDate {
                            continue
                        }
                        if logEntry.date == lastEntryDate, logEntry.composedMessage == self.lastEntryMessage {
                            continue
                        }
                    }

                    newEntries.append(
                        Entry(
                            date: logEntry.date,
                            category: logEntry.category,
                            level: logEntry.level,
                            message: logEntry.composedMessage
                        )
                    )
                    latestDate = logEntry.date
                }

                if let latestDate {
                    self.lastEntryDate = latestDate
                    self.lastEntryMessage = newEntries.last?.message ?? self.lastEntryMessage
                    self.position = store.position(date: latestDate)
                }

                if !newEntries.isEmpty {
                    self.pendingEntries.append(contentsOf: newEntries)
                }

                self.flushIfNeeded(now: now, cutoff: cutoff, sessionStart: sessionStart)
            } catch {
                let entry = Entry(
                    date: Date(),
                    category: "system",
                    level: .error,
                    message: "Failed to read logs: \(error.localizedDescription)"
                )
                self.pendingEntries.append(entry)
                self.flushIfNeeded(now: Date(), cutoff: Date().addingTimeInterval(-self.historyWindow), sessionStart: self.sessionStart ?? Date())
            }
        }
    }

    private func flushIfNeeded(now: Date, cutoff: Date, sessionStart: Date) {
        guard now.timeIntervalSince(lastFlushDate) >= 0.7 else { return }
        lastFlushDate = now

        let newEntries = pendingEntries
        pendingEntries.removeAll()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let trimmedEntries = self.entries.filter { entry in
                entry.date >= cutoff || entry.date >= sessionStart
            }
            if trimmedEntries.count != self.entries.count {
                self.entries = trimmedEntries
            }

            guard !newEntries.isEmpty else { return }
            self.entries.append(contentsOf: newEntries)
        }
    }

    private func observeAppActivity() {
        removeActivityObservers()

        let center = NotificationCenter.default
        activeObservers = [
            center.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                self?.isActive = true
            },
            center.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
                self?.isActive = false
            }
        ]
    }

    private func removeActivityObservers() {
        let center = NotificationCenter.default
        activeObservers.forEach { center.removeObserver($0) }
        activeObservers.removeAll()
    }
}

private extension OSLogEntryLog.Level {

    var displayName: String {
        switch self {
        case .undefined:
            return "Undefined"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .error:
            return "Error"
        case .fault:
            return "Fault"
        @unknown default:
            return "Unknown"
        }
    }
}
