import UIKit

protocol AlbumLoader: class {
    func fetchAllPhotosPreview(targetSize: CGSize, handler: Album -> Void)
    func fetchFavoritesPreview(targetSize: CGSize, handler: Album -> Void)
    func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: Album -> Void)
    func fetchAllSmartAlbumPreviews(targetSize: CGSize, handler: Album -> Void)
}