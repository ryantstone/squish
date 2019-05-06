import Cocoa

class ProgressViewController: NSViewController {

    @IBOutlet weak var progressLabel: NSTextFieldCell! {
        didSet {
            progressLabel.isEditable = false
            progressLabel.textColor  = .white
        }
    }

    public func updateProgress(_ progress: Int) {
        progressLabel.stringValue = "\(progress)%"
    }

    public func didComplete() {
        progressLabel.stringValue = "Complete"
    }
}
