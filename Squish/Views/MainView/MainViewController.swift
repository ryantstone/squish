import Cocoa

class MainViewController: NSWindowController {
    lazy var importerViewController = ImporterViewController.init(nibName: "ImporterViewController", bundle: nil)
    lazy var metadataViewController = MetadataView.init(nibName: "MetadataView", bundle: nil)
    var files = [URL]()
    var fileData: FileData!
    var mp3Joiner: MP3Joiner!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setup()
    }
    
    func setup() {
        loadView(importerViewController)
        importerViewController.delegate = self
        metadataViewController.delegate = self
    }
    
    func loadView(_ viewController: NSViewController) {
        window?.contentViewController?.present(viewController, animator: ReplacePresentationAnimator())
//        window?.contentViewController = viewController
    }
}

extension MainViewController: ImporterViewControllerDelegate {
    func didReceiveFiles(_ files: [URL]) {
        self.files = files
        loadView(metadataViewController)
    }
}

extension MainViewController: MetadataViewDelegate {
    func didTapExport(metadata: MetadataViewModel) {
        fileData            = FileData(files: files, metaData: metadata)
        mp3Joiner           = MP3Joiner(fileData)
        mp3Joiner.delegate  = self
        mp3Joiner.perform()
    }
}

extension MainViewController: Mp3JoinerDelegate {
    func didProgress(_ progress: Int) {
        print("Progress: \(progress)%")
    }
    
    func didFinish(joinedFileURL: URL) {
        print(joinedFileURL)
    }
}

