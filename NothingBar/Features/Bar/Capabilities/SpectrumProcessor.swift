import Accelerate
import Foundation

struct SpectrumLevels: Equatable {
    var bass: Float = 0
    var mid: Float = 0
    var treble: Float = 0
    var bassPeak: Float = 0
    var midPeak: Float = 0
    var treblePeak: Float = 0
}

final class SpectrumProcessor {
    private let size = 2048
    private let sampleRate: Float
    private let setup = vDSP_create_fftsetup(11, FFTRadix(kFFTRadix2))
    private let window: [Float]
    private var samples = [Float]()
    private var smoothed = SpectrumLevels()

    init(sampleRate: Float) {
        self.sampleRate = sampleRate
        var window = [Float](repeating: 0, count: size)
        vDSP_hann_window(&window, vDSP_Length(size), Int32(vDSP_HANN_NORM))
        self.window = window
    }

    deinit {
        if let setup { vDSP_destroy_fftsetup(setup) }
    }

    func consume<Input: Collection>(_ input: Input) -> SpectrumLevels? where Input.Element == Float {
        samples.append(contentsOf: input)
        var latest: SpectrumLevels?
        while samples.count >= size {
            latest = processFrame()
            samples.removeFirst(size / 4)
        }
        return latest
    }

    private func processFrame() -> SpectrumLevels? {
        guard let setup else { return nil }
        let frame = Array(samples.prefix(size))
        var signal = [Float](repeating: 0, count: size)
        vDSP_vmul(frame, 1, window, 1, &signal, 1, vDSP_Length(size))
        var real = [Float](repeating: 0, count: size / 2)
        var imaginary = [Float](repeating: 0, count: size / 2)
        real.withUnsafeMutableBufferPointer { realBuffer in
            imaginary.withUnsafeMutableBufferPointer { imaginaryBuffer in
                var split = DSPSplitComplex(realp: realBuffer.baseAddress!, imagp: imaginaryBuffer.baseAddress!)
                signal.withUnsafeBufferPointer { signalBuffer in
                    signalBuffer.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: size / 2) {
                        vDSP_ctoz($0, 2, &split, 1, vDSP_Length(size / 2))
                    }
                }
                vDSP_fft_zrip(setup, &split, 1, vDSP_Length(11), FFTDirection(FFT_FORWARD))
            }
        }

        let binWidth = sampleRate / Float(size)
        func energy(_ low: Float, _ high: Float) -> Float {
            let lower = max(1, Int(low / binWidth))
            let upper = min(size / 2 - 1, Int(high / binWidth))
            guard lower <= upper else { return 0 }
            var sum: Float = 0
            for i in lower...upper { sum += real[i] * real[i] + imaginary[i] * imaginary[i] }
            let rms = sqrt(sum / Float(upper - lower + 1)) / Float(size)
            return min(1, max(0, (20 * log10(max(rms, 0.00001)) + 65) / 55))
        }
        let raw = SpectrumLevels(bass: energy(20, 250), mid: energy(250, 4_000), treble: energy(4_000, 20_000))
        func smooth(_ old: Float, _ new: Float) -> Float {
            old + (new - old) * (new > old ? 0.35 : 0.08)
        }
        smoothed = SpectrumLevels(
            bass: smooth(smoothed.bass, raw.bass),
            mid: smooth(smoothed.mid, raw.mid),
            treble: smooth(smoothed.treble, raw.treble),
            bassPeak: max(smoothed.bass, smoothed.bassPeak - 0.008),
            midPeak: max(smoothed.mid, smoothed.midPeak - 0.008),
            treblePeak: max(smoothed.treble, smoothed.treblePeak - 0.008)
        )
        smoothed.bassPeak = max(smoothed.bassPeak, smoothed.bass)
        smoothed.midPeak = max(smoothed.midPeak, smoothed.mid)
        smoothed.treblePeak = max(smoothed.treblePeak, smoothed.treble)
        return smoothed
    }
}
