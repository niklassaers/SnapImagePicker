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
    
    func loadedAlbum(type: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int) {
        presenter?.presentAlbum(type, withMainImage: mainImage, albumSize: albumSize)
    }
    
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>, withTargetSize targetSize: CGSize) {
        entityGateway?.fetchAlbumImagesFromAlbum(type, inRange: range, withTargetSize: targetSize)
    }
    
    func loadedAlbumImagesResult(results: [Int:SnapImagePickerImage], fromAlbum album: AlbumType) {
        presenter?.presentAlbumImages(results, fromAlbum: album)
    }
    
    func loadMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        entityGateway?.fetchMainImageFromAlbum(type, atIndex: index)
    }
    
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        presenter?.presentMainImage(image, fromAlbum: album)
    }
}