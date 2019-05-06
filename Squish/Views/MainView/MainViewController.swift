import Cocoa

class MainViewController: NSWindowController {
    lazy var importerViewController = ImporterViewController.init(nibName: "ImporterViewController", bundle: nil)
    lazy var metadataViewController = MetadataView(nibName: "MetadataView", bundle: nil)
    lazy var progressViewController = ProgressViewController(nibName: "ProgressViewController", bundle: nil)
    var files = [URL]()
    var fileData: FileData!
    var mp3Joiner: AudioConcatenator!
    
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
        loadView(progressViewController)
        fileData            = FileData(files: files, metaData: metadata)
        mp3Joiner           = AudioConcatenator(fileData)
        mp3Joiner.delegate  = self
        mp3Joiner.perform()
    }
}

extension MainViewController: Mp3JoinerDelegate {
    func didProgress(_ progress: Int) {
        progressViewController.updateProgress(progress)
    }
    
    func didFinish(joinedFileURL: URL) {
        progressViewController.didComplete()
    }
}

