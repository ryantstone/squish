import Cocoa
import AVFoundation

class MetadataWriter {
    
    let metadata: MetadataViewModel
    var title: AVMutableMetadataItem {
        let songName        = AVMutableMetadataItem()
        songName.value      = metadata.titleText as NSString
        songName.identifier = AVMetadataIdentifier.commonIdentifierTitle
        return songName
    }
    var metadataItems: [AVMutableMetadataItem] {
        return [title]
    }
    
    init(metadata: MetadataViewModel) {
        self.metadata = metadata
    }
    
//    func write() {
//        let songName        = AVMutableMetadataItem()
//        songName.value      = metadata.titleText as NSString
//        songName.identifier = AVMetadataIdentifier.commonIdentifierTitle
//    }
}
