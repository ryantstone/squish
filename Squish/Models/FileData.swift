import Foundation
import AVFoundation

typealias Seconds = Double

struct FileData {
    var metaData = Metadata()
    var files: [URL]

    var combinedTrackLength: Seconds  {
        return files.reduce(0, { (total, url) -> Double in
            let duration = AVURLAsset(url: url).duration
            return total + CMTimeGetSeconds(duration)
        })
    }


    init(files: [URL]) {
        self.files = FileData.sortFiles(files)
    }

    private static func sortFiles(_ files: [URL]) -> [URL] {
        return files.sorted(by: { $0.absoluteString.compare($1.absoluteString,
                                                            options: .numeric) == .orderedAscending })
    }

    public mutating func moveFile(from originalIndex: Int, to destinationIndex: Int) {
        files.move(from: originalIndex, to: destinationIndex)
        print(files.map { $0.lastPathComponent})
    }
}
