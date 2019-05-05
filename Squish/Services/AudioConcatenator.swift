import Foundation
import AVFoundation

class AudioConcatenator {
    
    // MARK: - Constants
    let fileData: FileData
    
    // MARK: - Delegate
    var delegate: Mp3JoinerDelegate?
    
    // MARK: - Computed Properties
    var metadata: MetadataViewModel { return fileData.metaData }
    var files: [URL] { return fileData.files }
    var totalTrackLength: Seconds { return fileData.combinedTrackLength }
    var sortedFiles: [URL] { return fileData.sortedFiles }
    var fullExportPath: String { return self.exportPath + self.exportFilename }
    var exportFileURL: URL? { return URL(string: fullExportPath) }
    var currentProgress: Int { return Int((self.currentCompletedSeconds / self.totalTrackLength) * 100) }
    
    // MARK: - Variables
    var currentCompletedSeconds: Seconds = 0
    var fileContents: String { return files.map { $0.path }.joined(separator: "|") }
    let exportPath      = FileManager.default.homeDirectoryForCurrentUser.path + "/Desktop/"
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
            "\(exportPath)\(exportFilename)"
        ])

        task.arguments = args

        var pipe = Pipe()
        setStdErrPipe(pipe: &pipe, task: &task)
        setTerminationNotification(task: task)

        task.launch()
    }

    // Adds metadata for the given key/value pair when passed a non-empty string
    private func addMetadata(for key: String, with value: String, into args: inout [String]) {
        guard !value.isEmpty else { return }
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

protocol Mp3JoinerDelegate {
    func didProgress(_ progress: Int)
    func didFinish(joinedFileURL: URL)
}
