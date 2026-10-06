//
//  BarAudioEQView.swift
//  NothingBar
//
//  Created by Artem Belkov on 24.01.2026.
//

import AppKit
import Perception
import QuartzCore
import SwiftNothingEar
import SwiftUI

struct BarAudioEQView: View {
    @Environment(AppData.self) private var appData
    @State private var showingSpectrumDisclosure = false
    let supportedEqPresets: [EQPreset]

    private var deviceState: DeviceState { appData.deviceState }
    private var analyzer: SystemAudioAnalyzer { appData.audioAnalyzer }

    var body: some View {
        WithPerceptionTracking {
            let preset = deviceState.eqPreset ?? supportedEqPresets.first ?? .balanced
            let gains = deviceState.eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)
            let liveSpectrumEnabled = appData.liveSpectrumEnabled
            let supportsCustomEQ = supportedEqPresets.contains(.custom)
            let isExpanded = supportsCustomEQ && appData.isEqualizerExpanded
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    if supportsCustomEQ {
                        expandButton(isExpanded: isExpanded)
                    } else {
                        Text("Equalizer").font(.subheadline)
                    }
                    Spacer()
                    if #available(macOS 14.2, *), supportsCustomEQ {
                        Button {
                            if liveSpectrumEnabled {
                                appData.liveSpectrumEnabled = false
                            } else {
                                showingSpectrumDisclosure = true
                            }
                        } label: {
                            Image(systemName: liveSpectrumEnabled && !analyzer.captureFailed ? "waveform.circle.fill" : "waveform.circle")
                                .foregroundStyle(liveSpectrumEnabled && !analyzer.captureFailed ? Color.accentColor : .secondary)
                        }
                        .buttonStyle(.plain)
                        .help(spectrumButtonLabel(enabled: liveSpectrumEnabled))
                        .accessibilityLabel(spectrumButtonLabel(enabled: liveSpectrumEnabled))
                        // Hidden rather than removed: the icon is taller than the text, so removing it changes the row height.
                        .opacity(isExpanded ? 1 : 0)
                        .allowsHitTesting(isExpanded)
                        .accessibilityHidden(!isExpanded)
                    }
                    presetMenu(current: preset, gains: gains)
                }
                if isExpanded {
                    editor(gains: gains, editable: preset == .custom)
                        .frame(maxWidth: .infinity)
                        .frame(height: 184)
                        .onAppear { appData.isSpectrumVisible = true }
                        .onDisappear { appData.isSpectrumVisible = false }
                }
            }
            .padding(.horizontal, 4)
            .alert(String(localized: "See your sound live"), isPresented: $showingSpectrumDisclosure) {
                Button(String(localized: "Not now"), role: .cancel) {}
                Button(String(localized: "Show live levels")) { appData.liveSpectrumEnabled = true }
            } message: {
                Text("Animate the EQ with your Mac's sound. macOS will ask to capture audio and show an indicator. NothingBar processes it only in memory; nothing is recorded or shared. The EQ works without it.")
            }
        }
    }

    private func expandButton(isExpanded: Bool) -> some View {
        Button {
            appData.isEqualizerExpanded.toggle()
        } label: {
            HStack(spacing: 4) {
                Text("Equalizer").font(.subheadline)
                // Not animated: an implicit animation also moves the chevron while the panel resizes.
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 10, height: 10)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isExpanded ? String(localized: "Hide equalizer") : String(localized: "Show equalizer"))
        .accessibilityLabel(String(localized: "Equalizer"))
        .accessibilityValue(isExpanded ? String(localized: "Expanded") : String(localized: "Collapsed"))
    }

    private func spectrumButtonLabel(enabled: Bool) -> String {
        if analyzer.captureFailed { return String(localized: "Live audio unavailable. The EQ still works.") }
        guard enabled else { return String(localized: "Show live levels") }
        // A denied capture permission delivers silence rather than an error, so it looks the same as no playback.
        if !analyzer.isAvailable {
            return String(localized: "Hide live levels. If no levels appear during playback, allow NothingBar to record system audio in System Settings › Privacy & Security.")
        }
        return String(localized: "Hide live levels")
    }

    private func editor(gains: EQPresetCustom, editable: Bool) -> some View {
        EQEditorView(
            analyzer: analyzer,
            gains: gains,
            editable: editable,
            setBass: { editable ? setGains(bass: $0) : switchToCustom(bass: $0) },
            setMid: { editable ? setGains(mid: $0) : switchToCustom(mid: $0) },
            setTreble: { editable ? setGains(treble: $0) : switchToCustom(treble: $0) }
        )
    }

    private func setGains(bass: Int? = nil, mid: Int? = nil, treble: Int? = nil) {
        let current = deviceState.eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)
        let updated = EQPresetCustom(bass: bass ?? current.bass, mid: mid ?? current.mid, treble: treble ?? current.treble)
        appData.nothing.setCustomEQPreset(updated)
        deviceState.eqPresetCustom = updated
        AppLogger.audio.uiSettingChanged("EQ Custom", value: "\(updated.bass), \(updated.mid), \(updated.treble)")
    }

    private func presetMenu(current: EQPreset, gains: EQPresetCustom) -> some View {
        let profile = current == .custom ? EQProfile.matching(gains) : nil
        return Menu {
            Section(String(localized: "Nothing Profiles")) {
                ForEach(supportedEqPresets.filter { $0 != .custom }, id: \.self) { preset in
                    presetItem(preset, isSelected: current == preset)
                }
            }
            if supportedEqPresets.contains(.custom) {
                Section(String(localized: "App Profiles")) {
                    presetItem(.custom, isSelected: current == .custom && profile == nil)
                    ForEach(EQProfile.general) { item in
                        profileItem(item, isSelected: item == profile)
                    }
                    // Models with genre presets of their own would list Pop or Rock twice.
                    if !supportedEqPresets.contains(.pop) {
                        Menu(String(localized: "Music styles")) {
                            ForEach(EQProfile.musicStyles) { item in
                                profileItem(item, isSelected: item == profile)
                            }
                        }
                    }
                }
            }
        } label: { BarMenuLabel(title: profile?.name ?? current.localizedDisplayName) }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
    }

    private func presetItem(_ preset: EQPreset, isSelected: Bool) -> some View {
        menuItem(preset.menuDisplayName, isSelected: isSelected) {
            appData.nothing.setEQPreset(preset)
            deviceState.eqPreset = preset
        }
        .help(preset.menuHelp)
    }

    private func profileItem(_ profile: EQProfile, isSelected: Bool) -> some View {
        menuItem(profile.name, isSelected: isSelected) {
            switchToCustom(bass: profile.gains.bass, mid: profile.gains.mid, treble: profile.gains.treble)
        }
    }

    /// A toggle renders the native checkmark next to the selected menu item.
    private func menuItem(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Toggle(title, isOn: Binding(get: { isSelected }, set: { _ in action() }))
    }

    /// Switches to the custom preset, keeping the saved gains for bands that aren't passed.
    private func switchToCustom(bass: Int? = nil, mid: Int? = nil, treble: Int? = nil) {
        appData.nothing.setEQPreset(.custom)
        deviceState.eqPreset = .custom
        setGains(bass: bass, mid: mid, treble: treble)
    }
}

/// Observes live levels on its own so their ~30 Hz updates don't re-render the header and preset menu.
private struct EQEditorView: View {
    @Environment(\.colorSchemeContrast) private var contrast
    let analyzer: SystemAudioAnalyzer
    let gains: EQPresetCustom
    let editable: Bool
    let setBass: (Int) -> Void
    let setMid: (Int) -> Void
    let setTreble: (Int) -> Void

    var body: some View {
        WithPerceptionTracking {
            let levels = analyzer.isAvailable ? analyzer.levels : nil
            let peaks = analyzer.levels
            GeometryReader { geometry in
                let columns = geometry.size.width / 3
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(Color.primary.opacity(contrast == .increased ? 0.32 : 0.12))
                        .frame(height: 1)
                        .offset(y: (geometry.size.height - 34) / 2)
                        .allowsHitTesting(false)
                    HStack(spacing: 0) {
                        band(String(localized: "Bass"), value: editable ? gains.bass : 0, width: columns, level: levels?.bass, peak: peaks.bassPeak, set: setBass)
                        band(String(localized: "Mid"), value: editable ? gains.mid : 0, width: columns, level: levels?.mid, peak: peaks.midPeak, set: setMid)
                        band(String(localized: "Treble"), value: editable ? gains.treble : 0, width: columns, level: levels?.treble, peak: peaks.treblePeak, set: setTreble)
                    }
                }
            }
        }
    }

    private func band(_ title: String, value: Int, width: CGFloat, level: Float?, peak: Float, set: @escaping (Int) -> Void) -> some View {
        VStack(spacing: 2) {
            VerticalEQSlider(value: Binding(get: { value }, set: set), range: -6...6, label: title, isFactoryMode: !editable, level: level, peak: peak)
                .frame(width: 44)
                .frame(maxHeight: .infinity)
            if editable {
                Text(formattedGain(value))
                    .font(.caption2.monospacedDigit())
            } else {
                Text("—").font(.caption2)
                    .help(String(localized: "Factory sound mode; gain unavailable"))
            }
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: width)
    }
}

private func formattedGain(_ value: Int) -> String {
    let number = value > 0 ? "+\(value)" : "\(value)"
    return String(localized: "\(number) dB", comment: "Equalizer band gain, e.g. '+2 dB'")
}

private struct VerticalEQSlider: NSViewRepresentable {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    let isFactoryMode: Bool
    let level: Float?
    let peak: Float

    func makeCoordinator() -> Coordinator { Coordinator(value: $value) }

    func makeNSView(context: Context) -> NSSlider {
        let slider = GlassEQSlider()
        slider.cell = HorizontalKnobSliderCell()
        slider.minValue = Double(range.lowerBound)
        slider.maxValue = Double(range.upperBound)
        slider.doubleValue = Double(value)
        slider.isVertical = true
        slider.altIncrementValue = 1
        slider.numberOfTickMarks = range.upperBound - range.lowerBound + 1
        slider.allowsTickMarkValuesOnly = false
        if #available(macOS 26.0, *) {
            slider.neutralValue = 0
            slider.tintProminence = .primary
        }
        slider.isContinuous = true
        slider.target = context.coordinator
        slider.action = #selector(Coordinator.changed(_:))
        slider.setAccessibilityLabel(label)
        slider.installGlassHandle()
        return slider
    }

    func updateNSView(_ slider: NSSlider, context: Context) {
        context.coordinator.value = $value
        // NSViewRepresentable doesn't forward `.disabled` to the control.
        slider.isEnabled = context.environment.isEnabled
        slider.minValue = Double(range.lowerBound)
        slider.maxValue = Double(range.upperBound)
        if let slider = slider as? GlassEQSlider {
            if !slider.isAdjusting { slider.doubleValue = Double(value) }
            slider.isFactoryMode = isFactoryMode
            slider.setSpectrum(level: level, peak: peak)
        } else {
            slider.doubleValue = Double(value)
        }
        slider.setAccessibilityValue(isFactoryMode ? String(localized: "Factory sound mode; gain unavailable") : formattedGain(value))
        slider.setAccessibilityHelp(isFactoryMode
            ? String(localized: "Move to switch to your custom EQ.")
            : String(localized: "Use the arrow keys to adjust the equalizer gain."))
    }

    final class Coordinator: NSObject {
        var value: Binding<Int>
        init(value: Binding<Int>) { self.value = value }
        @objc func changed(_ sender: NSSlider) {
            let rounded = Int(sender.doubleValue.rounded())
            (sender as? GlassEQSlider)?.positionHandle()
            guard rounded != value.wrappedValue else { return }
            NSHapticFeedbackManager.defaultPerformer.perform(
                rounded == 0 || rounded == Int(sender.minValue) || rounded == Int(sender.maxValue) ? .alignment : .levelChange,
                performanceTime: .now
            )
            value.wrappedValue = rounded
        }
    }
}

private final class GlassEQSlider: NSSlider {
    var isAdjusting = false
    var isFactoryMode = false {
        didSet { updateHandleAlpha() }
    }
    override var isEnabled: Bool {
        didSet { updateHandleAlpha() }
    }
    private var glassHandle: NSView?
    private var spectrumMark: NSView?

    func installGlassHandle() {
        guard #available(macOS 14.0, *) else { return }
        let mark = SpectrumMarkView(frame: .zero)
        spectrumMark = mark
        addSubview(mark)
        if #available(macOS 26.0, *) {
            let glass = EQGlassHandle(frame: .zero)
            glass.style = .regular
            glass.cornerRadius = 7
            if #available(macOS 27.0, *) { glass.effectIsInteractive = true }
            addSubview(glass)
            glassHandle = glass
            (cell as? HorizontalKnobSliderCell)?.drawsGlass = true
        }
        positionHandle()
    }

    private func updateHandleAlpha() {
        glassHandle?.alphaValue = isFactoryMode || !isEnabled ? 0.55 : 1
    }

    func setSpectrum(level: Float?, peak: Float) {
        if #available(macOS 14.0, *) { (spectrumMark as? SpectrumMarkView)?.setSpectrum(level: level, peak: peak) }
        positionHandle()
    }

    func positionHandle() {
        guard let cell = cell as? NSSliderCell else { return }
        let rect = cell.knobRect(flipped: isFlipped)
        glassHandle?.frame = rect
        let rail = cell.barRect(flipped: isFlipped)
        spectrumMark?.frame = NSRect(x: rail.midX - 3, y: rail.minY, width: 6, height: rail.height)
    }

    override func layout() {
        super.layout()
        positionHandle()
    }

    override func mouseDown(with event: NSEvent) {
        isAdjusting = true
        super.mouseDown(with: event)
        isAdjusting = false
        doubleValue = doubleValue.rounded()
        positionHandle()
    }

    override func keyDown(with event: NSEvent) {
        let direction: Double
        switch event.keyCode {
        case 126, 124: direction = 1
        case 125, 123: direction = -1
        default:
            super.keyDown(with: event)
            return
        }
        doubleValue = min(maxValue, max(minValue, doubleValue.rounded() + direction))
        positionHandle()
        sendAction(action, to: target)
    }
}

@available(macOS 26.0, *)
private final class EQGlassHandle: NSGlassEffectView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

private final class HorizontalKnobSliderCell: NSSliderCell {
    var drawsGlass = false
    override func drawTickMarks() {}

    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let rail = NSRect(x: rect.midX - 3, y: rect.minY, width: 6, height: rect.height)
        NSColor.labelColor.withAlphaComponent(NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? 0.26 : 0.10).setFill()
        NSBezierPath(roundedRect: rail, xRadius: 3, yRadius: 3).fill()
    }

    override func knobRect(flipped: Bool) -> NSRect {
        let native = super.knobRect(flipped: flipped)
        return NSRect(x: native.midX - 15, y: native.midY - 7, width: 30, height: 14)
    }

    override func drawKnob(_ knobRect: NSRect) {
        guard !drawsGlass else { return }
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.12)
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.set()
        let knob = NSBezierPath(roundedRect: knobRect, xRadius: 7, yRadius: 7)
        NSColor.controlBackgroundColor.setFill()
        knob.fill()
        NSGraphicsContext.restoreGraphicsState()

        NSColor.separatorColor.setStroke()
        knob.lineWidth = 0.5
        knob.stroke()
    }
}

@available(macOS 14.0, *)
private final class SpectrumMarkView: NSView {
    private var targetLevel: CGFloat?
    private var targetPeak: CGFloat = 0
    private var displayedLevel: CGFloat = 0
    private var displayedPeak: CGFloat = 0
    private var displayLink: CADisplayLink?

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateDisplayLink()
    }

    func setSpectrum(level: Float?, peak: Float) {
        targetLevel = level.map { CGFloat(min(1, max(0, $0))) }
        targetPeak = CGFloat(min(1, max(0, peak)))
        if level == nil || NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            displayedLevel = targetLevel ?? 0
            displayedPeak = targetPeak
            needsDisplay = true
        }
        updateDisplayLink()
    }

    private func updateDisplayLink() {
        guard window != nil, targetLevel != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            displayLink?.invalidate()
            displayLink = nil
            return
        }
        guard displayLink == nil else { return }
        let link = displayLink(target: self, selector: #selector(advance(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func advance(_ link: CADisplayLink) {
        guard let targetLevel else { return }
        let elapsed = min(link.duration, 1.0 / 30.0)
        let levelRate = targetLevel > displayedLevel ? 24.0 : 10.0
        let levelBlend = 1 - exp(-elapsed * levelRate)
        let peakBlend = 1 - exp(-elapsed * 7.0)
        displayedLevel += (targetLevel - displayedLevel) * levelBlend
        displayedPeak += (targetPeak - displayedPeak) * peakBlend
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard targetLevel != nil else { return }
        let height = max(0, bounds.height - 4)
        let center = bounds.midX
        NSColor.controlAccentColor.setFill()
        NSBezierPath(roundedRect: NSRect(x: center - 1.5, y: 2, width: 3, height: max(1, height * displayedLevel)), xRadius: 1.5, yRadius: 1.5).fill()
        NSRect(x: center - 3, y: 2 + height * displayedPeak, width: 6, height: 1.5).fill()
    }
}

/// Editorial starting points for the custom EQ: research does not prescribe universal genre gains.
private struct EQProfile: Identifiable, Equatable {
    let id: String
    let name: String
    let gains: EQPresetCustom

    private init(_ id: String, _ name: String, bass: Int, mid: Int, treble: Int) {
        self.id = id
        self.name = name
        self.gains = EQPresetCustom(bass: bass, mid: mid, treble: treble)
    }

    // Computed so names follow an in-app language change.
    static var general: [EQProfile] {
        [
            EQProfile("warm", String(localized: "Warm"), bass: 2, mid: 0, treble: -1),
            EQProfile("detail", String(localized: "Detail"), bass: -1, mid: 1, treble: 2),
            EQProfile("podcast", String(localized: "Podcast"), bass: -2, mid: 2, treble: 0)
        ]
    }

    static var musicStyles: [EQProfile] {
        [
            EQProfile("pop", String(localized: "Pop"), bass: 1, mid: 0, treble: 1),
            EQProfile("rock", String(localized: "Rock"), bass: 1, mid: 1, treble: 0),
            EQProfile("hipHop", String(localized: "Hip-hop"), bass: 2, mid: -1, treble: 0),
            EQProfile("electronic", String(localized: "Electronic"), bass: 2, mid: -1, treble: 1)
        ]
    }

    static func matching(_ gains: EQPresetCustom) -> EQProfile? {
        (general + musicStyles).first { $0.gains == gains }
    }
}

private extension EQPreset {
    var menuDisplayName: String {
        self == .custom ? String(localized: "Custom · three bands") : localizedDisplayName
    }

    var menuHelp: String {
        switch self {
        case .custom: String(localized: "Adjust three fixed bands directly in NothingBar.")
        case .advanced: String(localized: "Use the advanced EQ set up in Nothing X.")
        default: localizedDisplayName
        }
    }

    var localizedDisplayName: String {
        switch self {
        case .balanced: String(localized: "Balanced", comment: "EQ preset name")
        case .voice: String(localized: "Voice", comment: "EQ preset name")
        case .moreTreble: String(localized: "More Treble", comment: "EQ preset name")
        case .moreBass: String(localized: "More Bass", comment: "EQ preset name")
        case .newVoice: String(localized: "New Voice", comment: "EQ preset name")
        case .newInstrument: String(localized: "New Instrument", comment: "EQ preset name")
        case .immersionBoost: String(localized: "Immersion Boost", comment: "EQ preset name")
        case .pop: String(localized: "Pop")
        case .rock: String(localized: "Rock")
        case .electronic: String(localized: "Electronic")
        case .enhanceVocals: String(localized: "Enhance Vocals", comment: "EQ preset name")
        case .classical: String(localized: "Classical", comment: "EQ preset name")
        case .custom: String(localized: "Custom", comment: "EQ preset name")
        case .advanced: String(localized: "Advanced", comment: "EQ preset name")
        }
    }
}
