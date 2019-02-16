import AppKit

public final class ImporterViewController: NSViewController {
    @IBOutlet weak var dropZoneView: DropzoneView!
    var files: [URL]? {
        didSet {
        }
    }
    
    public override func viewDidLoad() {
        dropZoneView.delegate = self
    }
}

extension ImporterViewController: DropzoneViewDelegate {
    func didReceiveFiles(_ files: [URL]) {
        self.files = files
//        mp3Joiner          = MP3Joiner(files)
//        mp3Joiner.delegate = self
//
//        mp3Joiner!.perform { (result) in
//            switch result {
//            case .success(let asset):
//                print(asset)
//            case .error(let error):
//                print(error)
//            }
//        }
    }
}



final class DropzoneView: NSView {
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    var fileTypeIsOk = false
    var droppedFilePath: [URL]! {
        didSet { delegate?.didReceiveFiles(droppedFilePath) }
    }
    let acceptedFileExtensions = [ "mp3", "mp4", "m4a", "m4b" ]
    let draggableTypes = [
        NSPasteboard.PasteboardType(kUTTypeFileURL as String),
        NSPasteboard.PasteboardType(kUTTypeItem as String)
    ]
    var delegate: DropzoneViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes(draggableTypes)
    }
    
    override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(drag: sender) {
            fileTypeIsOk = true
            return .copy
        } else {
            fileTypeIsOk = false
            return []
        }
    }
    
    override public func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let filePaths = parseDraggingInfo(sender) else { return false }
        droppedFilePath = filePaths.compactMap { URL(fileURLWithPath: $0) }
        return false
    }
    
    func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let filePaths = parseDraggingInfo(drag) else { return false }
        return filePaths.map { NSURL(fileURLWithPath: $0).pathExtension?.lowercased() }
            .unique
            .allSatisfy { acceptedFileExtensions.contains($0!) }
    }
    
    private func parseDraggingInfo(_ sender: NSDraggingInfo) -> [String]? {
        guard let files = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let filesPaths = files as? [String] else {
                return nil
        }
        return filesPaths
    }
}

protocol DropzoneViewDelegate {
    func didReceiveFiles(_ files: [URL])
}

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}
