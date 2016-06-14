import Foundation
import Photos

class AlbumSelectorInteractor {
    var presenter: AlbumSelectorPresenterInput?
    var loader: AlbumCollectionLoader?
}

protocol AlbumSelectorInteractorInput : class{
    func fetchAlbums()
}

extension AlbumSelectorInteractor: AlbumSelectorInteractorInput {
    func fetchAlbums() {
        if let loader = loader {
            loader.fetchAlbumCollectionWithHandler() {
                (album: PhotoAlbum) in
                self.presenter?.presentAlbum(album)
            }
        }
    }
}