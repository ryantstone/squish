import Foundation
import AVFoundation

class MP3Joiner {
    
    // MARK: - Constants
    let fileData: FileData
    
    // MARK: - Delegate
    var delegate: Mp3JoinerDelegate?
    
    // MARK: - Computed Properties
    var metadata: MetadataViewModel { return fileData.metaData }
    var files: [URL] { return fileData.files }
    var totalTrackLength: Seconds { return fileData.combinedTrackLength }
    var sortedFiles: [URL] { return fileData.sortedFiles }
    var fullExportPath: String { return self.exportFilename + self.exportFilename }
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
        
        let args: [String] = [
            "-i",
            #"concat:"\#(fileContents)""#,
            title(),
            artist(),
            narrator(),
            "-c:a",
            "libfdk_aac",
            "-vn",
            #"\#(exportPath)\#(exportFilename)"#
        ].compactMap { $0 }
        
        task.arguments = args

        var pipe = Pipe()
        setStdErrPipe(pipe: &pipe, task: &task)
        setTerminationNotification(task: task)

        task.launch()
    }

    func title() -> String? {
        guard metadata.titleText != "" else {
            return nil
        }
        return #"-metadata title="\#(metadata.titleText)""#
    }
    
    func artist() -> String? {
        guard metadata.authorText != "" else { return nil }
        return #"-metadata artist="\#(metadata.authorText)""#
    }
    
    func narrator() -> String? {
        guard metadata.narratorText != "" else { return nil }
        return #"-metadata album_artist="\#(metadata.narratorText)""#
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
                                                      queue: nil) { notification -> Void in
                                                        self.delegate?.didFinish(joinedFileURL: fileURL)
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
