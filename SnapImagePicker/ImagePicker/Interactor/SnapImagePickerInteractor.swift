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
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.fetchAlbum(type)
        }
    }
    
    func loadedAlbum(image: SnapImagePickerImage, albumSize: Int) {
        presenter?.presentAlbum(image, albumSize: albumSize)
    }
    
    func loadAlbumImageFromAlbum(type: AlbumType, atIndex index: Int) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.fetchAlbumImageFromAlbum(type, atIndex: index)
        }
    }
    
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.fetchAlbumImagesFromAlbum(type, inRange: range)
        }
    }
    
    func loadMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in self?.entityGateway?.fetchMainImageFromAlbum(type, atIndex: index)
        }
    }
    
    func loadedAlbumImage(image: SnapImagePickerImage, fromAlbum album: AlbumType, atIndex index: Int) {
        presenter?.presentAlbumImage(image, atIndex: index)
    }
    
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        presenter?.presentMainImage(image)
    }
}