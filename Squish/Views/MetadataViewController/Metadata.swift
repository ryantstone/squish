import Cocoa

struct Metadata {
    var albumArt: URL?
    var titleText: String?
    var authorText: String?
    var narratorText: String?
    private (set) var saveLocation: URL?

    public mutating func addAlbumArt(_ url: URL) {
        self.albumArt = url
    }

    public mutating func setSaveLocation(_ url: URL) {
        self.saveLocation = url
    }
}

