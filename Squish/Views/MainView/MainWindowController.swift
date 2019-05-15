import Cocoa

class MainWindowController: NSWindowController {
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
//        window?.toggleTabBar(nil)
    }
    
    func loadView(_ viewController: NSViewController) {
        window?.contentViewController?.present(viewController, animator: ReplacePresentationAnimator())
    }

    override func newWindowForTab(_ sender: Any?) {
        guard let newWindowController = self.storyboard?.instantiateInitialController() as? MainWindowController,
              let newWindow = newWindowController.window else { return }

        self.window?.addTabbedWindow(newWindow, ordered: .above)
    }
}

// MARK: - Importer View Controller Delegate
extension MainWindowController: ImporterViewControllerDelegate {
    func didReceiveFiles(_ files: [URL]) {
        self.files = files
        loadView(metadataViewController)
    }
}

// MARK: - Metadata View Delegate
extension MainWindowController: MetadataViewDelegate {
    func didTapExport(metadata: MetadataViewModel) {
        loadView(progressViewController)
        fileData            = FileData(files: files, metaData: metadata)
        mp3Joiner           = AudioConcatenator(fileData)
        mp3Joiner.delegate  = self
        mp3Joiner.perform()
    }
}

// MARK: - AudioConcatenator Delegate
extension MainWindowController: Mp3JoinerDelegate {
    func didProgress(_ progress: Int) {
        progressViewController.updateProgress(progress)
    }
    
    func didFinish(joinedFileURL: URL) {
        progressViewController.didComplete()
    }
}

