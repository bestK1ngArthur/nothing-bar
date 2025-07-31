//
//  SettingsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import AppKit

struct SettingsView: View {

    @Environment(AppData.self) private var appData
    @State private var selectedTab: SettingsTab = .device

    var body: some View {
        NavigationSplitView(
            columnVisibility: .constant(.all),
            sidebar: { sidebar },
            detail: { detail }
        )
        .frame(width: 715, height: 470)
    }

    private var sidebar: some View {
        List(SettingsTab.allCases, id: \.self, selection: $selectedTab) { tab in
            NavigationLink(value: tab) {
                Label(tab.title, systemImage: tab.icon)
            }
        }
        .toolbar(removing: .sidebarToggle)
        .listStyle(.sidebar)
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
        Group {
            switch selectedTab {
                case .device:
                    SettingsDeviceView()
                case .app:
                    SettingsAppView()
            }
        }
        .toolbar(removing: .title)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationSplitViewColumnWidth(min: 500, ideal: 500)
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
