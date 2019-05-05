import Cocoa

class MetadataView: NSViewController {
    // MARK: - Outlets
    @IBOutlet weak var albumArtImageWell: ImageWell!
    @IBOutlet weak var titleTextfield: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var narratorTextField: NSTextField!
    @IBOutlet weak var exportButton: NSButton!

    // MARK: - Actions

    var delegate: MetadataViewDelegate?
    var viewModel  = MetadataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumArtImageWell.delegate = self
        titleTextfield.delegate    = self
        authorTextField.delegate   = self
        narratorTextField.delegate = self
        exportButton.target        = self
        exportButton.action        = #selector(didTapExportButton)
    }
    
    @objc func didTapExportButton() {
        delegate?.didTapExport(metadata: viewModel)
    }
   
}

extension MetadataView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        switch textField {
        case titleTextfield:
            viewModel.titleText    = textField.stringValue
        case authorTextField:
            viewModel.authorText   = textField.stringValue
        case narratorTextField:
            viewModel.narratorText = textField.stringValue
        default:
            fatalError()
        }
    }
}

extension MetadataView: ImageWellDelegate {
    func didDropImage(_ url: URL) {
        viewModel.addAlbumArt(url)
    }
}

protocol MetadataViewDelegate {
    func didTapExport(metadata: MetadataViewModel)
}

class ImageWell: NSImageView {

    var delegate: ImageWellDelegate?

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let dragSucceeded = super.performDragOperation(sender)
        if dragSucceeded == true {
            guard let filenameURL = NSURL(from: sender.draggingPasteboard) as URL? else {
                return false
            }

            delegate?.didDropImage(filenameURL)

            return true
        }
        return false

    }
}

protocol ImageWellDelegate {
    func didDropImage(_ url: URL)
}
