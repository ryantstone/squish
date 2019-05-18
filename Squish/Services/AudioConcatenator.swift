import Foundation
import AVFoundation

class AudioConcatenator {
    
    // MARK: - Constants
    let fileData: FileData
    
    // MARK: - Delegate
    var delegate: AudioConcatenatorDelegate?
    
    // MARK: - Computed Properties
    var metadata: Metadata { return fileData.metaData }
    var files: [URL] { return fileData.files }
    var totalTrackLength: Seconds { return fileData.combinedTrackLength }
    var temporaryExport: URL { return URL(fileURLWithPath: NSTemporaryDirectory() + self.exportFilename) }
    var temporaryExportPath: String { return temporaryExport.path }

    var exportFileURL: URL? { return metadata.saveLocation }
    var currentProgress: Int { return Int((self.currentCompletedSeconds / self.totalTrackLength) * 100) }
    
    // MARK: - Variables
    var currentCompletedSeconds: Seconds = 0
    var fileContents: String { return files.map { $0.path }.joined(separator: "|") }
    let exportFilename  = UUID().uuidString + ".m4a"

    // MARK: - Init
    init(_ fileData: FileData) {
        self.fileData = fileData
    }
    
    func perform() {
        export()
    }
    
    private func export() {
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: "") else { return }
        
        
        var task = Process()
        task.launchPath = ffmpegPath

        // Set up the input list and encoder
        var args: [String] = [
            "-i",
            "concat:\(fileContents)",
            "-c:a",
            "libfdk_aac"
        ]

        // Add metadata (if it exists)
        addMetadata(for: "title", with: metadata.titleText, into: &args)
        addMetadata(for: "album", with: metadata.titleText, into: &args)
        addMetadata(for: "artist", with: metadata.authorText, into: &args)
        addMetadata(for: "album_artist", with: metadata.narratorText, into: &args)

        // Add the output path
        args.append(contentsOf: [
            "-vn",
            temporaryExport.path
        ])

        task.arguments = args

        var pipe = Pipe()
        setStdErrPipe(pipe: &pipe, task: &task)
        setTerminationNotification(task: task)

        task.launch()
    }

    // Adds metadata for the given key/value pair when passed a non-empty string
    private func addMetadata(for key: String, with value: String?, into args: inout [String]) {
        guard let value = value else { return }
        args.append(contentsOf: [
            "-metadata",
            "\(key)=\(value)"
        ])
    }

    func concatString() -> String {
        return files
            .map { $0.path}
            .joined(separator: "|")
    }
    
    // FFMPEG outputs to STDERR not STDOUT
    func setStdErrPipe(pipe: inout Pipe, task: inout Process) {
        task.standardError = pipe
        
        // Set output file handle
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        // add observer
        var obs1 : NSObjectProtocol!
        obs1 = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSFileHandleDataAvailable,
            object: outHandle, queue: nil) { [unowned outHandle]  notification -> Void in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = String(data: data, encoding: .utf8) {
                        self.updateProgress(str)
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                } else {
                    print("EOF on stdout from process")
                    NotificationCenter.default.removeObserver(obs1!)
                }
        }
    }
    
    func setTerminationNotification(task: Process) {
        guard let fileURL = exportFileURL else { return }
        var obs2 : NSObjectProtocol!
        obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                      object: task,
                                                      queue: nil) { [weak self] notification -> Void in
                                                        guard let strongSelf = self else { return }
                                                        if let exportUrl = strongSelf.exportFileURL {
                                                            AlbumArtService.call(strongSelf.metadata, fileUrl: exportUrl)

                                                            guard let saveLocation = strongSelf.metadata.saveLocation else { return }
                                                            MoveService.call(temporary: strongSelf.temporaryExport, destination: saveLocation)
                                                        }

                                                        strongSelf.delegate?.didFinish(joinedFileURL: fileURL)
                                                        NotificationCenter.default.removeObserver(obs2!)
        }
    }
    
    func updateProgress(_ text: String) {
        let result = ProgressCalculationService.call(text)
        
        switch result {
        case .success(let progress):
            self.currentCompletedSeconds = progress
            delegate?.didProgress(currentProgress)
        case .failure(let error):
            print(error)
        }
    }
}

protocol AudioConcatenatorDelegate {
    func didProgress(_ progress: Int)
    func didFinish(joinedFileURL: URL)
}
