//import Foundation
//
//class AlbumPresenter {
//    weak var view: AlbumViewControllerProtocol?
//}
//
//
//extension AlbumPresenter: AlbumPresenterProtocol {
//    func presentAlbumImage(response: Image_Response) {
//        view?.displayAlbumImage(response)
//    }
//    
//    func presentMainImage(response: Image_Response) {
//        view?.displayMainImage(response)
//    }
//    
//    func presentAlbumPreview(album: PhotoAlbum) {
//        print("Presenting album preview")
//        view?.addAlbumPreview(album)
//    }
//}
//
//extension AlbumPresenter: AlbumEventHandlerProtocol {
//    
//}