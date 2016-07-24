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
    
    func loadAlbumImageFromAlbum(type: AlbumType, atIndex index: Int) {
        entityGateway?.fetchAlbumImageFromAlbum(type, atIndex: index)
    }
    
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>) {
        entityGateway?.fetchAlbumImagesFromAlbum(type, inRange: range)
    }
    
    func loadMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        entityGateway?.fetchMainImageFromAlbum(type, atIndex: index)
    }
    
    func loadedAlbumImage(image: SnapImagePickerImage, fromAlbum album: AlbumType, atIndex index: Int) {
        presenter?.presentAlbumImage(image, atIndex: index)
    }
    
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        presenter?.presentMainImage(image)
    }
}