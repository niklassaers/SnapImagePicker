import UIKit

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
                albumSizeLabel?.text = formatSizeLabelText(album.size)
                if album.albumName == AlbumType.AllPhotos.getAlbumName() {
                    albumNameLabel?.text = L10n.AllPhotosAlbumName.string
                } else if album.albumName == AlbumType.Favorites.getAlbumName() {
                    albumNameLabel?.text = L10n.FavoritesAlbumName.string
                } else {
                    albumNameLabel?.text = album.albumName
                }
            }
        }
    }
        
    private func formatSizeLabelText(size: Int) -> String {
        return String(size) + " " + ((size == 1) ?  L10n.ImageLabelText.string : L10n.SeveralImagesLabelText.string)
    }
}
