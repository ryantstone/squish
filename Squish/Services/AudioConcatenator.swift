import Foundation
import AVFoundation

class MP3Joiner {
    let files: [URL]
    var delegate: Mp3JoinerDelegate?
    var sortedFiles: [URL] {
        return self.files.sorted(by: { $0.absoluteString.compare($1.absoluteString,
                                                                 options: .numeric) == .orderedAscending })
    }
    let metadata: MetadataViewModel
    
    init(_ files: [URL], metadata: MetadataViewModel) {
        self.files    = files
        self.metadata = metadata
    }
    
    func perform(completion: @escaping (Result<AVAsset>) -> ()) {
        let joinedTrack = join()
        export(joinedTrack) { completion($0) }
    }
    
    // FIXME: CLASS SHOULD BE BROKEN INTO 3 PARTS JOINING, EXPORTING, META DATA WRITING
    private func join() -> AVMutableComposition {
        let asset            = AVMutableComposition()
        let totalFileCount   = Double(sortedFiles.count)
        let compositionTrack = asset.addMutableTrack(withMediaType: AVMediaType.audio,
                                                     preferredTrackID: CMPersistentTrackID())
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for (index, track) in self.sortedFiles.enumerated() {
                do {
                    try compositionTrack?.append(url: track)
                    self.updateProgress(current: index, total: totalFileCount)
                } catch {
                    print(error)
                }
            }
        }
        return asset
    }
    
    private func updateProgress(current: Int, total: Double) {
        let current = Double(current)
        delegate?.didProgress(current/total)
    }
    
    private func export(_ asset: AVMutableComposition, completion: @escaping (Result<AVAsset>) -> ()) {
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: "") else { return }
        

        // FIXME: REFACTOR
        let fileContents    = files.map { $0.path }.joined(separator: "|")
        let exportPath      = FileManager.default.homeDirectoryForCurrentUser.path + "/Desktop/"
        let exportFilename  = UUID().uuidString + ".m4a"
        let task = Process()
        task.launchPath = ffmpegPath
        
        task.arguments = [
            "-i",
            #"concat:\#(fileContents)"#,
            "-c:a",
            "libfdk_aac",
            "-vn",
            #"\#(exportPath)\#(exportFilename)"#
        ]
       
       
        let pipe = Pipe()
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        var obs1 : NSObjectProtocol!
        obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                      object: outHandle, queue: nil) {  notification -> Void in
                                                        let data = outHandle.availableData
                                                        if data.count > 0 {
                                                            if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                                                print("got output: \(str)")
                                                            }
                                                            outHandle.waitForDataInBackgroundAndNotify()
                                                        } else {
                                                            print("EOF on stdout from process")
                                                            NotificationCenter.default.removeObserver(obs1)
                                                        }
        }
        
        var obs2 : NSObjectProtocol!
        obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                      object: task, queue: nil) { notification -> Void in
                                                        print("terminated")
                                                        NotificationCenter.default.removeObserver(obs2)
        }
        
        
        
        
        
        
        
        task.launch()


        
       
        
        
        
        
        
        
        
//        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Desktop/newFile.m4a")
//        guard let export: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
//            completion(.error("Export Failure"))
//            return
//        }
//
//        export.outputFileType               = AVFileType.m4a
//        export.outputURL                    = savePathUrl
//        export.shouldOptimizeForNetworkUse  = false
////        export.metadata = MetadataWriter(metadata: metadata).metadataItems
//        export.exportAsynchronously { () -> Void in
//            switch export.status {
//
//            case AVAssetExportSession.Status.completed:
//                print("success")
//            case  AVAssetExportSession.Status.failed:
//                completion(.error("\(export.error!)"))
//            case AVAssetExportSession.Status.cancelled:
//                completion(.error("\(export.error!)"))
//            default:
//                completion(.success(AVAsset(url: savePathUrl)))
//            }
//        }
    }
    
    func concatString() -> String {
        return files.map { $0.path}
                    .joined(separator: "|")
    }
}

protocol Mp3JoinerDelegate {
    func didProgress(_ progress: Double)
}

enum Result<T> {
    case success(T)
    case error(String)
}


extension AVMutableCompositionTrack {
    public func append(url: URL) throws {
        let newAsset = AVURLAsset(url: url)
        let range    = CMTimeRangeMake(start: CMTime.zero, duration: newAsset.duration)
        let end      = timeRange.end
        
        if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
            try insertTimeRange(range, of: track, at: end)
        }
    }
}
