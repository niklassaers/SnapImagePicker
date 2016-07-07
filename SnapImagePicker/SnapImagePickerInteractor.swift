import UIKit

class SnapImagePickerInteractor {
    private weak var presenter: SnapImagePickerPresenterProtocol?
    
    var entityGateway: SnapImagePickerEntityGatewayProtocol?
    
    init(presenter: SnapImagePickerPresenterProtocol) {
        self.presenter = presenter
    }
}

extension SnapImagePickerInteractor: SnapImagePickerInteractorProtocol {
    func loadInitialAlbum(type: AlbumType) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.loadInitialAlbum(type)
        }
    }
    
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex index: Int) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.loadAlbumImageWithType(type, withTargetSize: targetSize, atIndex: index)
        }
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.loadImageWithLocalIdentifier(localIdentifier)
        }
    }
    
    func initializedAlbum(image: SnapImagePickerImage, albumSize: Int) {
        presenter?.presentInitialAlbum(image, albumSize: albumSize)
    }
    
    func loadedAlbumImage(image: SnapImagePickerImage, atIndex index: Int) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in self?.presenter?.presentAlbumImage(image, atIndex: index)
        }
    }
    
    func loadedMainImage(image: SnapImagePickerImage) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in self?.presenter?.presentMainImage(image)
        }
    }
}