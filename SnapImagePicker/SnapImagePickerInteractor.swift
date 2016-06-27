import UIKit

class SnapImagePickerInteractor {
    private weak var presenter: SnapImagePickerPresenterProtocol?
    private var entityGateway: SnapImagePickerEntityGatewayProtocol?
    
    init(presenter: SnapImagePickerPresenterProtocol) {
        self.presenter = presenter
        entityGateway = SnapImagePickerEntityGateway(interactor: self)
    }
}

extension SnapImagePickerInteractor: SnapImagePickerInteractorProtocol {
    func loadAlbumWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        entityGateway?.loadAlbumWithLocalIdentifier(localIdentifier, withTargetSize: targetSize)
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