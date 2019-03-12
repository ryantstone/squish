import AppKit

extension NSView {
    static func buildNib<T: NSView>() -> T? {
        let nibName = String(describing: self)
        
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects) {
            return topLevelObjects?.firstObject as? T
            
        }
        assertionFailure("Unable to load a nibView for \(nibName)")
        return T()
    }
}
