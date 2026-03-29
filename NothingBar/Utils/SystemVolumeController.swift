import Foundation

@Observable
class SystemVolumeController {
    
    var volume: Float = 0.5 {
        didSet {
            setSystemVolume(volume)
        }
    }
    
    private var volumeUpdateTimer: Timer?
    
    init() {
        self.volume = getSystemVolume()
        startVolumeMonitoring()
    }
    
    func getSystemVolume() -> Float {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "output volume of (get volume settings)"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let volumeString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               let volumeInt = Int(volumeString) {
                return Float(volumeInt) / 100.0
            }
        } catch {
            print("Failed to get system volume: \(error)")
        }
        
        return 0.5
    }
    
    private func setSystemVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        let volumePercent = Int(clampedVolume * 100)
        
        let script = "set volume output volume \(volumePercent)"
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        
        do {
            try task.run()
        } catch {
            print("Failed to set system volume: \(error)")
        }
    }
    
    private func startVolumeMonitoring() {
        // Poll system volume every 0.5 seconds to stay in sync
        volumeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                let currentVolume = self?.getSystemVolume() ?? 0.5
                if abs(currentVolume - (self?.volume ?? 0.5)) > 0.01 {
                    self?.volume = currentVolume
                }
            }
        }
    }
    
    deinit {
        volumeUpdateTimer?.invalidate()
    }
}

