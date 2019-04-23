import Foundation

class ProgressCalculationService {
    let progressText: String
    let pattern = #"size=\s*\d*\w{2}\stime=(?<hours>\d{2}):(?<minutes>\d{2}):(?<seconds>\d{2}).(?<subseconds>\d{2})\sbitrate=\s*(?<bitrate>\d*).(?<subBitrate>\d*)(?<bitrateTime>\w*)\/s\s*speed=(?<speed>\d*.\d*)x"#
    lazy var regex = { try! NSRegularExpression(pattern: pattern, options: []) }()
    lazy var range: NSRange = { return NSRange(self.progressText.startIndex..<self.progressText.endIndex, in: self.progressText) }()
    let components = ["hours", "minutes", "seconds", "subseconds", "bitrate", "subBitrate", "bitrateTime", "speed"]
    
    
    static func call(_ progressText: String) -> Result<Seconds, Error> {
        return ProgressCalculationService(progressText).perform()
    }
    
    init(_ progressText: String) {
        self.progressText = progressText
    }
    
    private func perform() -> Result<Seconds, Error> {
        let componentValues = extractValues()
        
        guard let hourString   = componentValues["hours"],
              let hours        = Int(hourString),
              let minuteString = componentValues["minutes"],
              let minutes      = Int(minuteString),
              let secondString = componentValues["seconds"],
              let seconds      = Int(secondString) else { return .failure(ProgressCalculationError.failedToDecodeValues) }
       
        let totalTime = Double((hours * 60 * 60) + (minutes * 60) + seconds)
        return .success(totalTime)
    }
    
    private func extractValues() -> [String: String] {
        if let match = regex.firstMatch(in: progressText, options: [], range: range) {
            return components.reduce([String: String]()) {(dict, component) in
                let matchComponentValue = match.range(withName: component)
                var dict = dict
                guard matchComponentValue.location != NSNotFound,
                    let matchComponentValueRange = Range(matchComponentValue, in: progressText) else { return dict }

                dict[component] = String(progressText[matchComponentValueRange])
                return dict
            }
        }
        return [:]
    }
}

enum ProgressCalculationError: Error {
    case failedToDecodeValues
}
