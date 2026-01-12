//
//  SettingsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import SwiftUI

struct SettingsView: View {

    @Environment(AppData.self) private var appData

    @State private var selectedTab: SettingsTab = .device
    @State private var didPresentUpdate = false

    var body: some View {
        NavigationSplitView(
            preferredCompactColumn: .constant(.detail),
            sidebar: { sidebar },
            detail: { detail }
        )
        .frame(width: 715, height: 470)
        .onAppear {
            presentUpdateIfNeeded()
        }
    }

    private var sidebar: some View {
        List(SettingsTab.allCases, id: \.self, selection: $selectedTab) { tab in
            NavigationLink(value: tab) {
                HStack(spacing: 6) {
                    Label(tab.title, systemImage: tab.icon)

                    Spacer()

                    if tab == .app && appData.appVersion.isUpdateAvailable {
                        updateBadge
                    }
                }
            }
        }
        .frame(width: 215)
        .overlay(alignment: .bottom) {
            Button(role: .destructive) {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                Text("Quit App")
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding()
        }
    }

    private var detail: some View {
        NavigationStack {
            switch selectedTab {
                case .device:
                    SettingsDeviceView()
                case .app:
                    SettingsAppView()
            }
        }
        .toolbar(removing: .title)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var updateBadge: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 6, height: 6)
            .padding(.trailing, 4)
    }

    private func presentUpdateIfNeeded() {
        guard !didPresentUpdate, appData.appVersion.isUpdateAvailable else { return }

        didPresentUpdate = true
        appData.appVersion.checkForUpdatesManually()
    }
}

private enum SettingsTab: String, CaseIterable {

    case device = "Device"
    case app = "App"

    var title: String {
        return self.rawValue
    }

    var icon: String {
        switch self {
        case .device:
            return "headphones"
        case .app:
            return "app.badge"
        }
    }
}
