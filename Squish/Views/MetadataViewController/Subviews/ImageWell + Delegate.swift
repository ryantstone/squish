import Cocoa

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
// MARK: - Image Well Deleage
protocol ImageWellDelegate {
    func didDropImage(_ url: URL)
}
