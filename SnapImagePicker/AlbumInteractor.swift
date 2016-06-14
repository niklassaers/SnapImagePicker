import Foundation

class AlbumInteractor {
    var presenter: AlbumPresenterInput?
    var loader: AlbumLoader?
}

protocol AlbumInteractorInput : class {
    func fetchImages(albumName: String)
}

extension AlbumInteractor: AlbumInteractorInput {
    func fetchImages(albumName: String) {
        if let loader = loader {
            loader.fetchAlbumWithHandler(albumName) {
                (image: UIImage) in
                self.presenter?.presentImage(image)
            }
        }
    }
}