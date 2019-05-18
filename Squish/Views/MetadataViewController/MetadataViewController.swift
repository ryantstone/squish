import Cocoa

class MetadataViewController: NSViewController {
    // MARK: - Outlets
    @IBOutlet weak var albumArtImageWell: ImageWell!
    @IBOutlet weak var titleTextfield: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var narratorTextField: NSTextField!
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var fileTableView: FileTableView!

    // MARK: - Properties
    var delegate: MetadataViewDelegate?
    var fileData: FileData!
    var cellIdentifier = "cell"

    // MARK: - Computed Properties
    var files: [URL] { return fileData.files }
    var metaData: Metadata { return fileData.metaData }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        albumArtImageWell.delegate = self
        titleTextfield.delegate    = self
        authorTextField.delegate   = self
        narratorTextField.delegate = self
        exportButton.target        = self
        exportButton.action        = #selector(didTapExportButton)
        fileTableView.configure(fileData)
    }

    // MARK: - Public Methods
    public func configure(_ fileData: FileData) {
        self.fileData = fileData
    }

    @objc private func didTapExportButton() {
        displaySavePanel()
    }

    private func displaySavePanel() {
        let savePanel               = NSSavePanel()
        savePanel.allowedFileTypes  = ["m4a", "m4b"]

        savePanel.begin { [unowned self] (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                guard let url = savePanel.url else { return }
                self.fileData.metaData.setSaveLocation(url)
                self.delegate?.didTapExport(metadata: self.metaData)
            }
        }
    }
}

// MARK: - Textfield Delegate
extension MetadataViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        switch textField {
        case titleTextfield:
            fileData.metaData.titleText    = textField.stringValue
        case authorTextField:
            fileData.metaData.authorText   = textField.stringValue
        case narratorTextField:
            fileData.metaData.narratorText = textField.stringValue
        default:
            fatalError()
        }
    }
}

// MARK: - Image Well Delegate
extension MetadataViewController: ImageWellDelegate {
    func didDropImage(_ url: URL) {
        fileData.metaData.addAlbumArt(url)
    }
}

// MARK: - MetadataViewDelegate Protocol
protocol MetadataViewDelegate {
    func didTapExport(metadata: Metadata)
}

