import UIKit

class SnapImagePickerInteractor {
    private weak var presenter: SnapImagePickerPresenterProtocol?
    
    var entityGateway: SnapImagePickerEntityGatewayProtocol?
    
    init(presenter: SnapImagePickerPresenterProtocol) {
        self.presenter = presenter
    }
}

extension SnapImagePickerInteractor: SnapImagePickerInteractorProtocol {
    func loadAlbum(type: AlbumType) {
        entityGateway?.fetchAlbum(type)
    }
    
    func loadedAlbum(image: SnapImagePickerImage, albumSize: Int) {
        presenter?.presentAlbum(image, albumSize: albumSize)
    }
    
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>) {
        entityGateway?.fetchAlbumImagesFromAlbum(type, inRange: range)
    }
    
    func loadMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        entityGateway?.fetchMainImageFromAlbum(type, atIndex: index)
    }
    
    func loadedAlbumImagesResult(results: [Int:SnapImagePickerImage], fromAlbum album: AlbumType) {
        presenter?.presentAlbumImages(results) // TODO: If album is dropped, was it needed at all?
    }
    
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        presenter?.presentMainImage(image)
    }
}