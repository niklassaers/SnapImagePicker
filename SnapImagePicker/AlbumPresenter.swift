import Foundation

class AlbumPresenter {
    weak var viewController: AlbumViewControllerInput?
}

protocol AlbumPresenterInput : class {
    func presentAlbumImage(response: Image_Response)
    func presentMainImage(response: Image_Response)
    func presentAlbumPreview(album: PhotoAlbum)
}

extension AlbumPresenter: AlbumPresenterInput {
    func presentAlbumImage(response: Image_Response) {
        viewController?.displayAlbumImage(response)
    }
    
    func presentMainImage(response: Image_Response) {
        viewController?.displayMainImage(response)
    }
    
    func presentAlbumPreview(album: PhotoAlbum) {
        viewController?.addAlbumPreview(album)
    }
}