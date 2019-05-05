import Foundation

class AlbumArtService {

    let mp4ArtBinary = Bundle.main.path(forResource: "mp4art", ofType: nil)
    let metadata: MetadataViewModel
    let fileUrl: URL
    var artworkPath: String!
    
    lazy var process = Process()
    lazy var arguments: [String] = [
        fileUrl.path,
        "--add",
        artworkPath
    ]

    public static func call(_ metadata: MetadataViewModel, fileUrl: URL) {
        AlbumArtService(metadata, fileUrl).perform()
    }

    private init(_ metadata: MetadataViewModel, _ fileUrl: URL) {
        self.metadata = metadata
        self.fileUrl = fileUrl
    }

    private func perform() {
        guard let artwork = metadata.albumArt,
              let mp4ArtBinary = self.mp4ArtBinary else { return }

        artworkPath        = artwork.path
        process.launchPath = mp4ArtBinary
        process.arguments  = arguments
        process.launch()
    }
}
