import UIKit
import Foundation

class AlbumCell: UITableViewCell {
    @IBOutlet weak var albumPreviewImageView: UIImageView? {
        didSet {
            albumPreviewImageView?.contentMode = .ScaleAspectFill
        }
    }
    @IBOutlet weak var albumNameLabel: UILabel?
    @IBOutlet weak var albumSizeLabel: UILabel?
    var displayFont: UIFont? {
        didSet {
            albumNameLabel?.font = displayFont
            albumSizeLabel?.font = displayFont
        }
    }
    
    var album: Album? {
        didSet {
            if let album = album {
                albumPreviewImageView?.image = album.image.square()
                albumNameLabel?.text = album.albumName
                albumSizeLabel?.text = formatSizeLabelText(album.size)
            }
        }
    }
        
    private func formatSizeLabelText(size: Int) -> String {
        return String(size) + " " + ((size == 1) ? "image" : "images")
    }
}
