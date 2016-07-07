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
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.loadAlbumWithType(type, withTargetSize: targetSize)
        }
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.loadImageWithLocalIdentifier(localIdentifier, withTargetSize: targetSize)
        }
    }
    
    func loadedAlbumImage(image: UIImage, localIdentifier: String) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in self?.presenter?.presentAlbumImage(image, id: localIdentifier)
        }
    }
    
    func loadedMainImage(image: UIImage, withLocalIdentifier identifier: String) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in self?.presenter?.presentMainImage(image, withLocalIdentifier: identifier)
        }
    }
}