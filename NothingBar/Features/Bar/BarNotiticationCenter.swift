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

    private var windows: [BarNotificationWindow] = []

    private let hMargin: CGFloat = 16
    private let vMargin: CGFloat = 16
    private let spacing: CGFloat = 10

    func show(with appData: AppData, duration: TimeInterval = 3.0, screen: NSScreen? = nil) {
        let view = BarNotificationView().environment(appData)
        let host = NSHostingView(rootView: view)
        host.translatesAutoresizingMaskIntoConstraints = false
        let panel = BarNotificationWindow(host: host)
        panel.alphaValue = 0

        host.layoutSubtreeIfNeeded()
        let size = host.fittingSize

        let scr = screen ?? (screenUnderMouse() ?? NSScreen.main ?? NSScreen.screens.first!)
        let vf = scr.visibleFrame

        let x = vf.maxX - size.width - hMargin
        let y = vf.maxY - vMargin - size.height - currentStackHeight(on: scr)

        panel.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = .init(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        windows.append(panel)

        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self, weak panel] _ in
            Task { @MainActor in
                guard let self, let panel else { return }
                self.dismiss(panel)
            }
        }
    }

    func dismissAll() {
        windows.forEach { dismiss($0) }
    }

    private func dismiss(_ panel: BarNotificationWindow) {
        guard let idx = windows.firstIndex(where: { $0 === panel }) else { return }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = .init(name: .easeIn)
            panel.animator().alphaValue = 0
            panel.setFrameOrigin(NSPoint(x: panel.frame.origin.x, y: panel.frame.origin.y))
        } completionHandler: {
            panel.orderOut(nil)
            panel.close()
        }
        windows.remove(at: idx)
        relayout()
    }

    private func relayout() {
        let grouped = Dictionary(grouping: windows, by: { $0.screen ?? NSScreen.main })
        for (scr, list) in grouped {
            guard let scr else { continue }
            let vf = scr.visibleFrame
            var top = vf.maxY - vMargin
            let sorted = list.sorted { $0.frame.origin.y > $1.frame.origin.y }
            for w in sorted {
                let x = vf.maxX - w.frame.width - hMargin
                let y = top - w.frame.height
                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.15
                    ctx.timingFunction = .init(name: .easeInEaseOut)
                    w.animator().setFrameOrigin(NSPoint(x: x, y: y))
                }
                top = y - spacing
            }
        }
    }

    private func currentStackHeight(on screen: NSScreen) -> CGFloat {
        let vf = screen.visibleFrame
        let stack = windows.filter { ($0.screen ?? NSScreen.main) == screen }
        var h: CGFloat = 0
        for w in stack {
            if vf.contains(w.frame.origin) { h += w.frame.height + spacing }
        }
        return h
    }

    private func screenUnderMouse() -> NSScreen? {
        let p = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(p, $0.frame, false) }
    }
}
