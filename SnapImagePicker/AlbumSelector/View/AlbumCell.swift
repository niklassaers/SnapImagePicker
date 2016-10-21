import UIKit

class AlbumCell: UITableViewCell {
    @IBOutlet weak var albumPreviewImageView: UIImageView? {
        didSet {
            albumPreviewImageView?.contentMode = .scaleAspectFill
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
                albumSizeLabel?.text = formatSizeLabelText(album.size)
                if album.albumName == AlbumType.allPhotos.getAlbumName() {
                    albumNameLabel?.text = L10n.allPhotosAlbumName.string
                } else if album.albumName == AlbumType.favorites.getAlbumName() {
                    albumNameLabel?.text = L10n.favoritesAlbumName.string
                } else {
                    albumNameLabel?.text = album.albumName
                }
            }
        }
    }
        
    fileprivate func formatSizeLabelText(_ size: Int) -> String {
        return String(size) + " " + ((size == 1) ?  L10n.imageLabelText.string : L10n.severalImagesLabelText.string)
    }
}
