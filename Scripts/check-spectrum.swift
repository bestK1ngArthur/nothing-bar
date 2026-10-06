// Run: swiftc -parse-as-library NothingBar/Features/Bar/Capabilities/SpectrumProcessor.swift Scripts/check-spectrum.swift -o /tmp/check-spectrum && /tmp/check-spectrum
import Foundation

@main
struct SpectrumCheck {
    static func main() {
        let rate: Float = 48_000
        for (frequency, band) in [(120.0, 0), (1_000.0, 1), (8_000.0, 2)] {
            let processor = SpectrumProcessor(sampleRate: rate)
            var levels = SpectrumLevels()
            for block in 0..<12 {
                let samples = (0..<512).map { index in
                    Float(sin(2 * .pi * frequency * Double(block * 512 + index) / Double(rate))) * 0.5
                }
                levels = processor.consume(samples) ?? levels
            }
            let values = [levels.bass, levels.mid, levels.treble]
            assert(values[band] > values[(band + 1) % 3] && values[band] > values[(band + 2) % 3], "Wrong band for \(frequency) Hz: \(values)")
        }
        let silent = SpectrumProcessor(sampleRate: rate).consume([Float](repeating: 0, count: 2048))!
        assert(silent == SpectrumLevels())
    }
}
