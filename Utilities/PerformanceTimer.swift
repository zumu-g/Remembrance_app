import Foundation

class PerformanceTimer {
    private let name: String
    private let startTime: CFAbsoluteTime
    
    init(_ name: String) {
        self.name = name
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func end() {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("⏱️ \(name): \(String(format: "%.3f", timeElapsed))s")
    }
}