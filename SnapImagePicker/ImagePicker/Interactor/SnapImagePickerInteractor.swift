import UIKit

class SnapImagePickerInteractor {
    fileprivate weak var presenter: SnapImagePickerPresenterProtocol?
    
    var entityGateway: SnapImagePickerEntityGatewayProtocol?
    
    init(presenter: SnapImagePickerPresenterProtocol) {
        self.presenter = presenter
    }
}

extension SnapImagePickerInteractor: SnapImagePickerInteractorProtocol {
    func loadAlbum(_ type: AlbumType) {
        entityGateway?.fetchAlbum(type)
    }
    
    func loadedAlbum(_ type: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int) {
        presenter?.presentAlbum(type, withMainImage: mainImage, albumSize: albumSize)
    }
    
    func loadAlbumImagesFromAlbum(_ type: AlbumType, inRange range: CountableRange<Int>, withTargetSize targetSize: CGSize) {
        self.entityGateway?.fetchAlbumImagesFromAlbum(type, inRange: range, withTargetSize: targetSize)
    }
    
    func loadedAlbumImagesResult(_ results: [Int:SnapImagePickerImage], fromAlbum album: AlbumType) {
        presenter?.presentAlbumImages(results, fromAlbum: album)
    }
    
    func loadMainImageFromAlbum(_ type: AlbumType, atIndex index: Int) {
        entityGateway?.fetchMainImageFromAlbum(type, atIndex: index)
    }
    
    func loadMainImageWithLocalIdentifier(_ localIdentifier: String, fromAlbum album: AlbumType) {
        entityGateway?.fetchImageWithLocalIdentifier(localIdentifier, fromAlbum: album)
    }
    
    func loadedMainImage(_ image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        presenter?.presentMainImage(image, fromAlbum: album)
    }
    
    func deleteImageRequestsInRange(_ range: CountableRange<Int>) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            self.entityGateway?.deleteImageRequestsInRange(range)
        }
    }
}
