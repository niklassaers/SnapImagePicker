import Foundation

class AlbumInteractor {
    var presenter: AlbumPresenterInput?
    var albumLoader: AlbumLoader?
}

protocol AlbumInteractorInput : class {
    func fetchAlbum(request: Album_Request)
    func fetchImage(request: Image_Request)
    func fetchAlbumPreviews()
}

extension AlbumInteractor: AlbumInteractorInput {
    func fetchAlbum(request: Album_Request) {
        if let loader = albumLoader {
            loader.fetchAlbumWithHandler(request.title, withTargetSize: request.size) {
                [weak self] (image: UIImage, id: String) in
                self?.presenter?.presentAlbumImage(Image_Response(image: image, id: id))
            }
        }
    }
    
    func fetchImage(request: Image_Request) {
        if let loader = albumLoader {
            loader.fetchImageFromId(request.id, withTargetSize: request.size) {
                [weak self] (image: UIImage, id: String) in
                self?.presenter?.presentMainImage(Image_Response(image: image, id: id))
            }
        }
    }
    
    func fetchAlbumPreviews() {
        if let loader = albumLoader {
            loader.fetchAlbumPreviewsWithTargetSize(CGSize(width: 64, height: 64)) {
                [weak self] (album: PhotoAlbum) in
                self?.presenter?.presentAlbumPreview(album)
            }
        }
    }
}