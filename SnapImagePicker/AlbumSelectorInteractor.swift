import UIKit

class AlbumSelectorInteractor {
    private weak var presenter: AlbumSelectorPresenterProtocol?
    private var entityGateway: AlbumSelectorEntityGatewayProtocol?
    
    init(presenter: AlbumSelectorPresenterProtocol) {
        self.presenter = presenter
        entityGateway = AlbumSelectorEntityGateway(interactor: self)
    }
}

extension AlbumSelectorInteractor: AlbumSelectorInteractorProtocol {
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize) {
        entityGateway?.fetchAlbumPreviewsWithTargetSize(targetSize) {
            [weak self] (collectionTitle: String, album: Album) in
            self?.presenter?.presentAlbumPreview(collectionTitle, album: album)
        }
    }
}