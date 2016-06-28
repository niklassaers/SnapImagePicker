import Foundation

protocol AlbumSelectorPresenterProtocol: class {
    func presentAlbumPreview(collectionTitle: String, album: Album)
}