import UIKit

class SnapImagePickerInteractor {
    private weak var presenter: SnapImagePickerPresenterProtocol?
    
    var entityGateway: SnapImagePickerEntityGatewayProtocol?
    
    init(presenter: SnapImagePickerPresenterProtocol) {
        self.presenter = presenter
    }
}

extension SnapImagePickerInteractor: SnapImagePickerInteractorProtocol {
    func loadAlbumWithType(type: AlbumType, withTargetSize targetSize: CGSize) {
        print("EntityGateway: \(entityGateway)")
        entityGateway?.loadAlbumWithType(type, withTargetSize: targetSize)
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        entityGateway?.loadImageWithLocalIdentifier(localIdentifier, withTargetSize: targetSize)
    }
    
    func loadedAlbumImage(image: UIImage, localIdentifier: String) {
        presenter?.presentAlbumImage(image, id: localIdentifier)
    }
    
    func loadedMainImage(image: UIImage) {
        presenter?.presentMainImage(image)
    }
}