//
//  BarNotiticationCenter.swift
//  NothingBar
//
//  Created by Artem Belkov on 29.09.2025.
//

import AppKit
import SwiftUI

final class BarNotificationWindow: NSPanel {

    init(host: NSView) {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .ignoresCycle, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovable = false
        worksWhenModal = true
        contentView = host
        becomesKeyOnlyIfNeeded = false
        isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class BarNotificationCenter {

    static let shared = BarNotificationCenter()

    private struct NotificationEntry {
        let panel: BarNotificationWindow
        let style: NotificationStyle
    }

    private var entries: [NotificationEntry] = []

    private let hMargin: CGFloat = 16
    private let classicTopMargin: CGFloat = 40
    private let appleTopMargin: CGFloat = 8
    private let spacing: CGFloat = 10

    func show(with appData: AppData, duration: TimeInterval = 3.0, screen: NSScreen? = nil) {
        let style = appData.notificationStyle
        let view = BarNotificationView(style: style).environment(appData)
        let host = NSHostingView(rootView: view)
        host.translatesAutoresizingMaskIntoConstraints = false
        let panel = BarNotificationWindow(host: host)
        panel.alphaValue = 0

        host.layoutSubtreeIfNeeded()
        let size = host.fittingSize

        let scr = screen ?? (screenUnderMouse() ?? NSScreen.main ?? NSScreen.screens.first!)
        let origin = positionOrigin(
            size: size,
            screen: scr,
            style: style,
            stackHeight: currentStackHeight(on: scr, style: style)
        )

        panel.setFrame(
            NSRect(x: origin.x, y: origin.y, width: size.width, height: size.height),
            display: true
        )
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = .init(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.setFrameOrigin(origin)
        }

        entries.append(.init(panel: panel, style: style))

        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self, weak panel] _ in
            Task { @MainActor in
                guard let self, let panel else { return }
                self.dismiss(panel)
            }
        }
    }

    func dismissAll() {
        entries.map(\.panel).forEach { dismiss($0) }
    }

    private func dismiss(_ panel: BarNotificationWindow) {
        guard let idx = entries.firstIndex(where: { $0.panel === panel }) else { return }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = .init(name: .easeIn)
            panel.animator().alphaValue = 0
            panel.setFrameOrigin(NSPoint(x: panel.frame.origin.x, y: panel.frame.origin.y))
        } completionHandler: {
            panel.orderOut(nil)
            panel.close()
        }
        entries.remove(at: idx)
        relayout()
    }

    private func relayout() {
        let grouped = Dictionary(grouping: entries) { entry in
            let scr = entry.panel.screen ?? NSScreen.main ?? NSScreen.screens.first!
            return GroupingKey(screen: scr, style: entry.style)
        }

        for (key, list) in grouped {
            let scr = screen(for: key.screenID)
            guard let scr else { continue }
            var stackHeight: CGFloat = 0
            let sorted = list.sorted { $0.panel.frame.origin.y > $1.panel.frame.origin.y }
            for entry in sorted {
                let w = entry.panel
                let origin = positionOrigin(
                    size: w.frame.size,
                    screen: scr,
                    style: entry.style,
                    stackHeight: stackHeight
                )
                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.15
                    ctx.timingFunction = .init(name: .easeInEaseOut)
                    w.animator().setFrameOrigin(origin)
                }
                stackHeight += w.frame.height + spacing
            }
        }
    }

    private func currentStackHeight(on screen: NSScreen, style: NotificationStyle) -> CGFloat {
        let frame = screen.frame
        let stack = entries
            .filter { $0.style == style }
            .map(\.panel)
            .filter { ($0.screen ?? NSScreen.main) == screen }
        var h: CGFloat = 0
        for w in stack {
            if frame.contains(w.frame.origin) { h += w.frame.height + spacing }
        }
        return h
    }

    private func positionOrigin(
        size: CGSize,
        screen: NSScreen,
        style: NotificationStyle,
        stackHeight: CGFloat
    ) -> NSPoint {
        switch style {
            case .classic:
                return classicPositionOrigin(size: size, screen: screen, stackHeight: stackHeight)
            case .apple:
                return applePositionOrigin(size: size, screen: screen, stackHeight: stackHeight)
        }
    }

    private func classicPositionOrigin(size: CGSize, screen: NSScreen, stackHeight: CGFloat) -> NSPoint {
        let frame = screen.frame
        let x = frame.maxX - size.width - hMargin
        let y = frame.maxY - classicTopMargin - size.height - stackHeight
        return NSPoint(x: x, y: y)
    }

    private func applePositionOrigin(size: CGSize, screen: NSScreen, stackHeight: CGFloat) -> NSPoint {
        let statusItemFrame = visibleStatusItemFrame(on: screen)
        let x: CGFloat

        if let statusItemFrame {
            x = statusItemFrame.midX - (size.width / 2)
        } else {
            x = screen.frame.midX - (size.width / 2)
        }

        let statusItemMinY = statusItemFrame?.minY ?? screen.visibleFrame.maxY
        let y = statusItemMinY - appleTopMargin - size.height - stackHeight

        let origin = NSPoint(
            x: max(screen.frame.minX + hMargin, min(x, screen.frame.maxX - size.width - hMargin)),
            y: y
        )

        return origin
    }

    private func visibleStatusItemFrame(on screen: NSScreen) -> NSRect? {
        guard let window = menuBarStatusItemWindow(on: screen) else { return nil }
        guard window.occlusionState.contains(.visible) else { return nil }
        return window.frame
    }

    private func menuBarStatusItemWindow(on screen: NSScreen) -> NSWindow? {
        let topEdge = screen.frame.maxY
        let topBand = CGRect(
            x: screen.frame.minX,
            y: screen.frame.maxY - 60,
            width: screen.frame.width,
            height: 60
        )

        let candidates = NSApp.windows.filter { window in
            guard window.isVisible else { return false }
            guard window.frame.intersects(topBand) else { return false }
            guard window.frame.maxY >= (topEdge - 1) else { return false }
            guard window.frame.height <= 60, window.frame.width <= 260 else { return false }
            guard !entries.contains(where: { $0.panel === window }) else { return false }
            return true
        }

        return candidates.max(by: { $0.frame.maxX < $1.frame.maxX })
    }

    private func screenUnderMouse() -> NSScreen? {
        let p = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(p, $0.frame, false) }
    }

    private func screen(for id: ObjectIdentifier) -> NSScreen? {
        NSScreen.screens.first { ObjectIdentifier($0) == id }
    }
}

private struct GroupingKey: Hashable {

    let screenID: ObjectIdentifier
    let style: NotificationStyle

    init(screen: NSScreen, style: NotificationStyle) {
        self.screenID = ObjectIdentifier(screen)
        self.style = style
    }

    static func == (lhs: GroupingKey, rhs: GroupingKey) -> Bool {
        lhs.screenID == rhs.screenID && lhs.style == rhs.style
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(screenID)
        hasher.combine(style)
    }
}
