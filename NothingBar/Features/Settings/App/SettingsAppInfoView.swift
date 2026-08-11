//
//  SettingsAppInfoView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI

struct SettingsAppInfoView: View {

    var body: some View {
        InfoRow(title: "Version", value: appVersion)
        InfoRow(title: "Build", value: appBuild)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? unknown
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? unknown
    }

    private var unknown: String {
        String(localized: "Unknown", comment: "Fallback value when app info is unavailable")
    }
}
