import CoreAudio
import Foundation
import Perception

private var defaultOutputAddress = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultOutputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
)

@Perceptible
final class SystemAudioAnalyzer {
    var levels = SpectrumLevels()
    var isAvailable = false
    var captureFailed = false

    @PerceptionIgnored private let ioQueue = DispatchQueue(label: "NothingBar.AudioTap", qos: .userInteractive)
    @PerceptionIgnored private let worker = DispatchQueue(label: "NothingBar.Spectrum", qos: .userInitiated)
    @PerceptionIgnored private let workSlot = DispatchSemaphore(value: 1)
    // ponytail: Bound callback work to 16K mono frames; raise this if tap buffers exceed that size.
    @PerceptionIgnored private var scratch = [Float](repeating: 0, count: 16_384)
    @PerceptionIgnored private var outputListener: AudioObjectPropertyListenerBlock?
    @PerceptionIgnored private var tapID = AudioObjectID(kAudioObjectUnknown)
    @PerceptionIgnored private var aggregateID = AudioObjectID(kAudioObjectUnknown)
    @PerceptionIgnored private var ioProcID: AudioDeviceIOProcID?
    @PerceptionIgnored private var outputID = AudioObjectID(kAudioObjectUnknown)
    @PerceptionIgnored private var processor: SpectrumProcessor?
    @PerceptionIgnored private var generation = 0
    @PerceptionIgnored private var lastPublishTime = 0.0

    func start() {
        guard outputListener == nil else { return }
        guard #available(macOS 14.2, *) else {
            captureFailed = true
            return
        }
        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            self?.reconnectIfNeeded()
        }
        guard AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &defaultOutputAddress, .main, listener) == noErr else {
            captureFailed = true
            return
        }
        outputListener = listener
        reconnectIfNeeded()
    }

    func stop() {
        if let outputListener {
            AudioObjectRemovePropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &defaultOutputAddress, .main, outputListener)
            self.outputListener = nil
        }
        tearDown()
        isAvailable = false
        captureFailed = false
        levels = SpectrumLevels()
    }

    private func reconnectIfNeeded() {
        guard let current = defaultOutputID(), current != kAudioObjectUnknown else {
            if outputID != kAudioObjectUnknown {
                tearDown()
                isAvailable = false
                levels = SpectrumLevels()
            }
            return
        }
        guard current != outputID else { return }
        tearDown()
        outputID = current
        isAvailable = false
        captureFailed = false
        if #available(macOS 14.2, *) {
            do {
                try createTap(for: current)
            } catch {
                tearDown()
                outputID = current
                isAvailable = false
                captureFailed = true
            }
        }
    }

    private func defaultOutputID() -> AudioObjectID? {
        var id = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &defaultOutputAddress, 0, nil, &size, &id) == noErr else { return nil }
        return id
    }

    private func stringProperty(_ selector: AudioObjectPropertySelector, of object: AudioObjectID) throws -> String {
        var address = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        var uid: CFString = "" as CFString
        var size = UInt32(MemoryLayout<CFString>.size)
        let status = withUnsafeMutablePointer(to: &uid) {
            AudioObjectGetPropertyData(object, &address, 0, nil, &size, $0)
        }
        guard status == noErr else { throw AudioError(status) }
        return uid as String
    }

    @available(macOS 14.2, *)
    private func createTap(for device: AudioObjectID) throws {
        let description = CATapDescription(monoGlobalTapButExcludeProcesses: [])
        description.name = "NothingBar Spectrum"
        description.isPrivate = true
        description.muteBehavior = .unmuted
        description.deviceUID = try stringProperty(kAudioDevicePropertyDeviceUID, of: device)
        try check(AudioHardwareCreateProcessTap(description, &tapID))

        var formatAddress = AudioObjectPropertyAddress(mSelector: kAudioTapPropertyFormat, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        var format = AudioStreamBasicDescription()
        var formatSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        try check(AudioObjectGetPropertyData(tapID, &formatAddress, 0, nil, &formatSize, &format))
        guard format.mFormatID == kAudioFormatLinearPCM,
              format.mFormatFlags & kAudioFormatFlagIsFloat != 0,
              format.mBitsPerChannel == 32,
              format.mBytesPerFrame == UInt32(MemoryLayout<Float>.size),
              format.mChannelsPerFrame == 1 else { throw AudioError(kAudioHardwareUnsupportedOperationError) }
        worker.sync {
            processor = SpectrumProcessor(sampleRate: Float(format.mSampleRate))
            lastPublishTime = 0
        }

        let tapUID = try stringProperty(kAudioTapPropertyUID, of: tapID) as CFString

        let aggregateDescription: [String: Any] = [
            kAudioAggregateDeviceNameKey: "NothingBar Spectrum",
            kAudioAggregateDeviceUIDKey: UUID().uuidString,
            kAudioAggregateDeviceIsPrivateKey: true,
            kAudioAggregateDeviceTapAutoStartKey: true,
            kAudioAggregateDeviceSubDeviceListKey: [],
            kAudioAggregateDeviceTapListKey: [[
                kAudioSubTapUIDKey: tapUID,
                kAudioSubTapDriftCompensationKey: true
            ]]
        ]
        try check(AudioHardwareCreateAggregateDevice(aggregateDescription as CFDictionary, &aggregateID))
        let tapGeneration = generation
        try check(AudioDeviceCreateIOProcIDWithBlock(&ioProcID, aggregateID, ioQueue) { [weak self] _, input, _, _, _ in
            self?.receive(input, generation: tapGeneration)
        })
        try check(AudioDeviceStart(aggregateID, ioProcID))
    }

    private func receive(_ input: UnsafePointer<AudioBufferList>, generation: Int) {
        guard workSlot.wait(timeout: .now()) == .success else { return }
        guard input.pointee.mNumberBuffers > 0,
              let data = input.pointee.mBuffers.mData else {
            workSlot.signal()
            return
        }
        let buffer = input.pointee.mBuffers
        let count = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
        guard count > 0, count <= scratch.count else {
            workSlot.signal()
            return
        }
        scratch.withUnsafeMutableBufferPointer { destination in
            destination.baseAddress!.update(from: data.assumingMemoryBound(to: Float.self), count: count)
        }
        worker.async { [weak self] in
            guard let self else { return }
            self.scratch.withUnsafeBufferPointer { buffer in
                self.analyze(UnsafeBufferPointer(rebasing: buffer.prefix(count)), generation: generation)
            }
            self.workSlot.signal()
        }
    }

    private func analyze(_ samples: UnsafeBufferPointer<Float>, generation: Int) {
        guard let result = processor?.consume(samples) else { return }
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastPublishTime >= 1.0 / 30 else { return }
        lastPublishTime = now
        DispatchQueue.main.async { [weak self] in
            guard let self, self.outputListener != nil, self.generation == generation else { return }
            if result.bass > 0 || result.mid > 0 || result.treble > 0 { self.isAvailable = true }
            self.levels = result
        }
    }

    private func tearDown() {
        generation &+= 1
        if let ioProcID {
            AudioDeviceStop(aggregateID, ioProcID)
            AudioDeviceDestroyIOProcID(aggregateID, ioProcID)
            self.ioProcID = nil
        }
        if aggregateID != kAudioObjectUnknown {
            AudioHardwareDestroyAggregateDevice(aggregateID)
            aggregateID = AudioObjectID(kAudioObjectUnknown)
        }
        if #available(macOS 14.2, *), tapID != kAudioObjectUnknown {
            AudioHardwareDestroyProcessTap(tapID)
        }
        tapID = AudioObjectID(kAudioObjectUnknown)
        outputID = AudioObjectID(kAudioObjectUnknown)
        worker.sync {
            processor = nil
            lastPublishTime = 0
        }
    }

    private func check(_ status: OSStatus) throws {
        guard status == noErr else { throw AudioError(status) }
    }

    private struct AudioError: Error {
        let status: OSStatus
        init(_ status: OSStatus) { self.status = status }
    }
}
