import Cocoa
import AVFoundation

class MetadataWriter {
    
    let metadata: Metadata
    var title: AVMutableMetadataItem {
        let songName        = AVMutableMetadataItem()
        songName.value      = metadata.titleText as NSString
        songName.identifier = AVMetadataIdentifier.commonIdentifierTitle
        return songName
    }
    var metadataItems: [AVMutableMetadataItem] {
        return [title]
    }
    
    init(metadata: Metadata) {
        self.metadata = metadata
    }
    
//    func write() {
//        let songName        = AVMutableMetadataItem()
//        songName.value      = metadata.titleText as NSString
//        songName.identifier = AVMetadataIdentifier.commonIdentifierTitle
//    }
}
