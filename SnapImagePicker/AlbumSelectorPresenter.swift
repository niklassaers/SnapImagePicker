import Foundation

class AlbumSelectorPresenter {
    weak var viewController: AlbumSelectorViewControllerInput?
}

protocol AlbumSelectorPresenterInput : class {
    func presentAlbum(album: PhotoAlbum)
}

extension AlbumSelectorPresenter: AlbumSelectorPresenterInput {
    func presentAlbum(album: PhotoAlbum) {
        viewController?.displayAlbum(album)
    }
}