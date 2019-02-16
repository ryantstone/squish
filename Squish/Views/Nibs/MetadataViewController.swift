import Cocoa

class MetadataViewController: NSViewController {
    
    @IBOutlet weak var albumArtImageWell: NSImageCell!
    @IBOutlet weak var titleTextfield: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var narratorTextField: NSTextField!
    @IBOutlet weak var exportButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
