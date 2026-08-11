//
//  SettingsAppSettingsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import ServiceManagement
import Perception
import SwiftUI

struct SettingsAppSettingsView: View {

    @Environment(AppData.self) private var appData

    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("hideMenuBarWhenDisconnected") private var hideMenuBarWhenDisconnected = false
    @AppStorage("appLanguage") private var appLanguageRawValue = AppLanguage.defaultValue.rawValue
    @State private var showRestartAlert = false

    private var appLanguage: Binding<AppLanguage> {
        Binding(
            get: { AppLanguage(rawValue: appLanguageRawValue) ?? .defaultValue },
            set: { newValue in
                appLanguageRawValue = newValue.rawValue
                stageLanguage(newValue)
                showRestartAlert = true
            }
        )
    }

    var body: some View {
        WithPerceptionTracking {
            Group {
                SettingsRow(
                    title: "App language",
                    description: "Choose the language used by the app interface"
                ) {
                    Picker("", selection: appLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .fixedSize()
                }

                SettingsRow(
                    title: "Launch at login",
                    description: "Automatically start app when you log in to your Mac"
                ) {
                    Toggle("", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { newValue in
                            setLaunchAtLogin(enabled: newValue)
                        }
                }

                SettingsRow(
                    title: "Automatic updates",
                    description: "Automatically download and install app updates in the background"
                ) {
                    Toggle(
                        "",
                        isOn: .init(
                            get: { appData.appVersion.isAutoUpdateEnabled },
                            set: { appData.appVersion.setAutoUpdateEnabled($0) }
                        )
                    )
                }

                SettingsRow(
                    title: "Hide bar item when disconnected",
                    description: "Hide app icon from menu bar when no headphones are connected"
                ) {
                    Toggle("", isOn: $hideMenuBarWhenDisconnected)
                        .onChange(of: hideMenuBarWhenDisconnected) { newValue in
                            appData.hideMenuBarWhenDisconnected = newValue
                        }
                }

                SettingsRow(
                    title: appData.appVersion.isUpdateAvailable ? "Update available" : "Check for updates",
                    description: "Current version: \(appData.appVersion.currentVersion)"
                ) {
                    Button(LocalizedStringKey(appData.appVersion.isUpdateAvailable ? "Update" : "Check Now")) {
                        appData.appVersion.checkForUpdatesManually()
                    }
                }
            }
            .onAppear {
                updateLaunchAtLoginState()
                appData.hideMenuBarWhenDisconnected = hideMenuBarWhenDisconnected
            }
            .alert("Restart required", isPresented: $showRestartAlert) {
                Button("Restart Now", role: .destructive) {
                    relaunchApp()
                }
                Button("Later", role: .cancel) { }
            } message: {
                Text("NothingBar needs to restart to apply the new language.")
            }
        }
    }

    /// `AppleLanguages` is the system key AppKit reads at launch to pick the bundle's active
    /// language, overriding the macOS system language for this app only. It only takes effect
    /// on the next launch, hence `relaunchApp()` below.
    private func stageLanguage(_ language: AppLanguage) {
        if language == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        }
    }

    /// Relaunches the app after this process exits so the replacement does not compete for
    /// the active Bluetooth connection while applying the staged `AppleLanguages` value.
    private func relaunchApp() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            AppLogger.main.logError("Failed to relaunch app: missing bundle identifier")
            return
        }

        let script = """
        while kill -0 "$1" 2>/dev/null; do
            sleep 0.1
        done
        /usr/bin/open -n "$2" || exec /usr/bin/open -n -b "$3"
        """
        let relauncher = Process()
        relauncher.executableURL = URL(fileURLWithPath: "/bin/sh")
        relauncher.arguments = [
            "-c",
            script,
            "nothingbar-relauncher",
            String(ProcessInfo.processInfo.processIdentifier),
            Bundle.main.bundleURL.path,
            bundleIdentifier
        ]

        do {
            try relauncher.run()
            NSApp.terminate(nil)
        } catch {
            AppLogger.main.logError("Failed to start app relauncher: \(error)")
        }
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                launchAtLogin = !enabled
            }
        } else {
            launchAtLogin = false
        }
    }

    private func updateLaunchAtLoginState() {
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            launchAtLogin = (status == .enabled)
        } else {
            launchAtLogin = false
        }
    }
}
