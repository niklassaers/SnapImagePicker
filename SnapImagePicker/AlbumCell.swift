import UIKit

class AlbumCell: UITableViewCell {
    @IBOutlet weak var albumPreviewImageView: UIImageView? {
        didSet {
            albumPreviewImageView?.contentMode = .ScaleAspectFill
        }
    }
    @IBOutlet weak var albumNameLabel: UILabel?
    @IBOutlet weak var albumSizeLabel: UILabel?
    
    var album: Album? {
        didSet {
            if let album = album {
                albumPreviewImageView?.image = album.image.square()
                albumNameLabel?.text = album.title
                albumSizeLabel?.text = formatSizeLabelText(album.size)
            }
        }
    }
        
    private func formatSizeLabelText(size: Int) -> String {
        return String(size) + " " + ((size == 1) ? "image" : "images")
    }
}
