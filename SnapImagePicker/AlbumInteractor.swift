import Foundation

class AlbumInteractor {
    var presenter: AlbumPresenterInput?
    var loader: AlbumLoader?
}

protocol AlbumInteractorInput : class {
    func fetchAlbum(request: Album_Request)
    func fetchImage(request: Image_Request)
}

extension AlbumInteractor: AlbumInteractorInput {
    func fetchAlbum(request: Album_Request) {
        if let loader = loader {
            loader.fetchAlbumWithHandler(request.title, withTargetSize: request.size) {
                (image: UIImage, id: String) in
                self.presenter?.presentAlbumImage(Image_Response(image: image, id: id))
            }
        }
    }
    
    func fetchImage(request: Image_Request) {
        if let loader = loader {
            loader.fetchImageFromId(request.id, withTargetSize: request.size) {
                (image: UIImage, id: String) in
                self.presenter?.presentMainImage(Image_Response(image: image, id: id))
            }
        }
    }
}