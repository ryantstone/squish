import Cocoa

class MetadataViewController: NSViewController {
    // MARK: - Outlets
    @IBOutlet weak var albumArtImageWell: ImageWell!
    @IBOutlet weak var titleTextfield: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var narratorTextField: NSTextField!
    @IBOutlet weak var exportButton: NSButton!

    // MARK: - Actions

    var delegate: MetadataViewDelegate?
    var metaData  = Metadata()
    
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
        displaySavePanel()
    }

    func displaySavePanel() {
        let savePanel               = NSSavePanel()
        savePanel.allowedFileTypes  = ["m4a", "m4b"]

        savePanel.begin { [unowned self] (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                guard let url = savePanel.url else { return }
                self.metaData.setSaveLocation(url)
                self.delegate?.didTapExport(metadata: self.metaData)
            }
        }
    }
}

extension MetadataViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        switch textField {
        case titleTextfield:
            metaData.titleText    = textField.stringValue
        case authorTextField:
            metaData.authorText   = textField.stringValue
        case narratorTextField:
            metaData.narratorText = textField.stringValue
        default:
            fatalError()
        }
    }
}

extension MetadataViewController: ImageWellDelegate {
    func didDropImage(_ url: URL) {
        metaData.addAlbumArt(url)
    }
}

protocol MetadataViewDelegate {
    func didTapExport(metadata: Metadata)
}
