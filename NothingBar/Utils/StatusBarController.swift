import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject {

    private let appData: AppData
    private let hostingController: NSHostingController<AnyView>
    private let panel: StatusBarPanel
    private let backgroundView = StatusBarBackgroundView()

    private var statusItem: NSStatusItem?
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?

    private static let autosaveName = "NothingBarStatusItem"
    private static let positionKey = "NSStatusItem Preferred Position \(autosaveName)"
    private static let savedPositionKey = "NothingBarStatusItemSavedPosition"

    var isInserted: Bool {
        statusItem != nil
    }

    init(appData: AppData) {
        self.appData = appData
        self.hostingController = NSHostingController(
            rootView: AnyView(StatusBarPanelView().environment(appData))
        )
        self.panel = StatusBarPanel()
        super.init()

        configurePanel()
        configureEventMonitors()
    }

    deinit {
        if let localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
        }

        if let globalEventMonitor {
            NSEvent.removeMonitor(globalEventMonitor)
        }
    }

    func sync(isConnected: Bool, hideWhenDisconnected: Bool) {
        let shouldShow = !hideWhenDisconnected || isConnected

        guard shouldShow else {
            closePopover()
            saveStatusItemPosition()
            removeStatusItem()
            return
        }

        restoreStatusItemPosition()
        insertStatusItemIfNeeded()
        updateStatusImage(isConnected: isConnected)
        updatePanelFrame()
    }

    private func saveStatusItemPosition() {
        let position = UserDefaults.standard.double(forKey: Self.positionKey)
        guard position > 0 else { return }
        UserDefaults.standard.set(position, forKey: Self.savedPositionKey)
    }

    private func restoreStatusItemPosition() {
        let saved = UserDefaults.standard.double(forKey: Self.savedPositionKey)
        guard saved > 0 else { return }
        UserDefaults.standard.set(saved, forKey: Self.positionKey)
    }

    private func removeStatusItem() {
        guard let statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
        self.statusItem = nil
    }

    func showPopover() {
        guard statusItem?.button != nil else { return }

        updatePanelFrame()

        if panel.isVisible {
            return
        }

        panel.makeKeyAndOrderFront(nil)
    }

    func closePopover() {
        panel.orderOut(nil)
    }

    @objc
    private func togglePopover(_ sender: Any?) {
        if panel.isVisible {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func configurePanel() {
        if #available(macOS 13.0, *) {
            hostingController.sizingOptions = [.preferredContentSize]
        }

        panel.onEscape = { [weak self] in
            self?.closePopover()
        }

        panel.contentView = backgroundView
        backgroundView.contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.setContentHuggingPriority(.required, for: .vertical)
        hostingController.view.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: backgroundView.contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: backgroundView.contentView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: backgroundView.contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: backgroundView.contentView.bottomAnchor),
        ])
    }

    private func configureEventMonitors() {
        localEventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]
        ) { [weak self] event in
            guard let self else { return event }

            if event.type == .keyDown, event.keyCode == 53, self.panel.isVisible {
                self.closePopover()
                return nil
            }

            guard self.panel.isVisible else {
                return event
            }

            if self.shouldClose(for: event) {
                self.closePopover()
            }

            return event
        }

        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] event in
            guard let self, self.panel.isVisible else { return }

            if self.shouldCloseForGlobalEvent(event) {
                self.closePopover()
            }
        }
    }

    private func shouldClose(for event: NSEvent) -> Bool {
        let screenPoint = screenLocation(for: event)
        return !panel.frame.contains(screenPoint) && !statusItemFrame.contains(screenPoint)
    }

    private func shouldCloseForGlobalEvent(_ event: NSEvent) -> Bool {
        let screenPoint = eventWindowLocationInScreen(for: event) ?? NSEvent.mouseLocation
        return !panel.frame.contains(screenPoint) && !statusItemFrame.contains(screenPoint)
    }

    private func screenLocation(for event: NSEvent) -> NSPoint {
        eventWindowLocationInScreen(for: event) ?? NSEvent.mouseLocation
    }

    private func eventWindowLocationInScreen(for event: NSEvent) -> NSPoint? {
        guard let window = event.window else {
            return nil
        }

        let location = window.convertPoint(toScreen: event.locationInWindow)
        return NSPoint(x: location.x, y: location.y)
    }

    private var statusItemFrame: NSRect {
        guard
            let button = statusItem?.button,
            let window = button.window
        else {
            return .zero
        }

        let rectInWindow = button.convert(button.bounds, to: nil)
        return window.convertToScreen(rectInWindow)
    }

    private func updatePanelFrame() {
        guard let button = statusItem?.button else { return }

        hostingController.view.layoutSubtreeIfNeeded()

        let fittingSize = hostingController.view.fittingSize
        let contentSize = NSSize(width: max(fittingSize.width, 320), height: fittingSize.height)
        panel.setContentSize(contentSize)

        let buttonFrame = statusItemFrame
        let screenFrame = button.window?.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero

        let originX = min(
            max(buttonFrame.minX, screenFrame.minX + 8),
            screenFrame.maxX - contentSize.width - 8
        )
        let originY = buttonFrame.minY - contentSize.height - 4

        panel.setFrameOrigin(NSPoint(x: originX, y: originY))
    }

    private func insertStatusItemIfNeeded() {
        guard statusItem == nil else { return }

        let newStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        newStatusItem.autosaveName = "NothingBarStatusItem"
        newStatusItem.button?.target = self
        newStatusItem.button?.action = #selector(togglePopover(_:))
        newStatusItem.button?.imagePosition = .imageOnly

        statusItem = newStatusItem
    }

    private func updateStatusImage(isConnected: Bool) {
        guard let button = statusItem?.button else { return }

        let symbolName = isConnected ? "headphones" : "headphones.slash"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Nothing Headphones")
        image?.isTemplate = true
        button.image = image
    }
}

private final class StatusBarPanel: NSPanel {

    var onEscape: (() -> Void)?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 360),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        animationBehavior = .none
        backgroundColor = .clear
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        hasShadow = true
        hidesOnDeactivate = false
        isFloatingPanel = true
        isMovableByWindowBackground = false
        isOpaque = false
        level = .statusBar
        titleVisibility = .hidden
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        false
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onEscape?()
            return
        }

        super.keyDown(with: event)
    }

    override func cancelOperation(_ sender: Any?) {
        onEscape?()
    }
}

private final class StatusBarBackgroundView: NSView {

    let contentView = NSView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        contentView.translatesAutoresizingMaskIntoConstraints = false

        if #available(macOS 26.0, *) {
            let glassView = NSGlassEffectView()
            glassView.translatesAutoresizingMaskIntoConstraints = false
            glassView.style = .regular
            glassView.cornerRadius = 14
            glassView.contentView = contentView
            addSubview(glassView)

            NSLayoutConstraint.activate([
                glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
                glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
                glassView.topAnchor.constraint(equalTo: topAnchor),
                glassView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        } else {
            let effectView = NSVisualEffectView()
            effectView.translatesAutoresizingMaskIntoConstraints = false
            effectView.blendingMode = .behindWindow
            effectView.material = .underWindowBackground
            effectView.state = .active
            effectView.wantsLayer = true
            effectView.layer?.cornerCurve = .continuous
            effectView.layer?.cornerRadius = 14
            effectView.layer?.masksToBounds = true
            effectView.addSubview(contentView)
            addSubview(effectView)

            NSLayoutConstraint.activate([
                effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
                effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
                effectView.topAnchor.constraint(equalTo: topAnchor),
                effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        layer?.cornerCurve = .continuous
        layer?.cornerRadius = 14
        layer?.masksToBounds = true

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct StatusBarPanelView: View {

    @Environment(AppData.self) private var appData

    var body: some View {
        BarView()
            .environment(appData)
    }
}
