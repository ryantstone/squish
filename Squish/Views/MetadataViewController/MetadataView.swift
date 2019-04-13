import Cocoa

class MetadataView: NSViewController {
    
    @IBOutlet weak var albumArtImageWell: NSImageCell! {
        didSet {
            viewModel.albumArt = albumArtImageWell.image
        }
    }
    
    @IBOutlet weak var titleTextfield: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var narratorTextField: NSTextField!
    @IBOutlet weak var exportButton: NSButton!

    var delegate: MetadataViewDelegate?
    var viewModel  = MetadataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

protocol MetadataViewDelegate {
    func didTapExport(metadata: MetadataViewModel)
}
