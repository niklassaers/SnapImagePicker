import UIKit

protocol AlbumLoaderProtocol: class {
    func fetchAllPhotosPreview(_ targetSize: CGSize, handler: @escaping (Album) -> ())
    func fetchFavoritesPreview(_ targetSize: CGSize, handler: @escaping (Album) -> ())
    func fetchAllUserAlbumPreviews(_ targetSize: CGSize, handler: @escaping (Album) -> ())
    func fetchAllSmartAlbumPreviews(_ targetSize: CGSize, handler: @escaping (Album) -> ())
}
