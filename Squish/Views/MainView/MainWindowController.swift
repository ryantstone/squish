import Cocoa

class MainWindowController: NSWindowController {
    lazy var importerViewController = ImporterViewController.init(nibName: "ImporterViewController", bundle: nil)
    lazy var metadataViewController: MetadataViewController = { [unowned self] in
        let vc = MetadataViewController(nibName: "MetadataView", bundle: nil)
        guard let fileData = self.fileData else {
            fatalError("Files improperly imported")
        }
        vc.delegate = self
        vc.configure(fileData)
        return vc
    }()
    lazy var progressViewController = ProgressViewController(nibName: "ProgressViewController", bundle: nil)
    var fileData: FileData?
    var mp3Joiner: AudioConcatenator!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setup()
    }
    
    func setup() {
        loadView(importerViewController)
        importerViewController.delegate = self
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
        fileData = FileData(files: files)
        loadView(metadataViewController)
    }
}

// MARK: - Metadata View Delegate
extension MainWindowController: MetadataViewDelegate {
    func didTapExport(metadata: Metadata) {
        guard let fileData = fileData else {
            fatalError("Improperly imported files")
        }
        loadView(progressViewController)
        mp3Joiner          = AudioConcatenator(fileData)
        mp3Joiner.delegate = self
        mp3Joiner.perform()
    }
}

// MARK: - AudioConcatenator Delegate
extension MainWindowController: AudioConcatenatorDelegate {
    func didProgress(_ progress: Int) {
        progressViewController.updateProgress(progress)
    }
    
    func didFinish(joinedFileURL: URL) {
        progressViewController.didComplete()
    }
}

