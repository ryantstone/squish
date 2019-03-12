import Cocoa

class MainViewController: NSViewController {
    lazy var importerViewController = ImporterViewController.init(nibName: "ImporterViewController", bundle: nil)
    lazy var metadataViewController = MetadataView.init(nibName: "MetadataView", bundle: nil)
    var files = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadView(importerViewController)
        importerViewController.delegate = self
        metadataViewController.delegate = self
    }
    
    func loadView(_ viewController: NSViewController) {
        addChild(viewController)
        view = viewController.view
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
        let audioConcat = MP3Joiner(files, metadata: metadata)
        audioConcat.perform { print($0)}
    }
}
