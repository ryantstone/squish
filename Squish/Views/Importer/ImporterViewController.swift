import AppKit

public final class ImporterViewController: NSViewController {
    @IBOutlet weak var dropZoneView: DropzoneView!
    var delegate: ImporterViewControllerDelegate?

    public override func viewDidLoad() {
        dropZoneView.delegate = self
    }
}

extension ImporterViewController: DropzoneViewDelegate {
    func didReceiveFiles(_ files: [URL]) {
        delegate?.didReceiveFiles(files)
    }
}

protocol ImporterViewControllerDelegate {
    func didReceiveFiles(_ files: [URL])
}
