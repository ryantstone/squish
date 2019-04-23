import Cocoa
import AVFoundation

typealias Seconds = Double

// FIXME: SHOULD THIS BE RENAMED?
struct MetadataViewModel {
    var albumArt: NSImage?
    var titleText    = ""
    var authorText   = ""
    var narratorText = ""
}

struct FileData {
    let metaData: MetadataViewModel
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
    
    init(files: [URL], metaData: MetadataViewModel) {
        self.files = files
        self.metaData = metaData
    }
}
