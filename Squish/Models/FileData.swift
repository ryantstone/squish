import Foundation
import AVFoundation

typealias Seconds = Double

struct FileData {
    let metaData: Metadata
    let files: [URL]

    var combinedTrackLength: Seconds  {
        return files.reduce(0, { (total, url) -> Double in
            let duration = AVURLAsset(url: url).duration
            return total + CMTimeGetSeconds(duration)
        })
    }

    var sortedFiles: [URL] {
        return files.sorted(by: { $0.absoluteString.compare($1.absoluteString,
                                                            options: .numeric) == .orderedAscending })
    }

    init(files: [URL], metaData: Metadata) {
        self.files = files
        self.metaData = metaData
    }
}
