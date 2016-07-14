import UIKit

class AlbumSelectorInteractor {
    private weak var presenter: AlbumSelectorPresenterProtocol?
    
    var entityGateway: AlbumSelectorEntityGatewayProtocol?
    
    init(presenter: AlbumSelectorPresenterProtocol) {
        self.presenter = presenter
    }
}

extension AlbumSelectorInteractor: AlbumSelectorInteractorProtocol {
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize) {
        entityGateway?.fetchAlbumPreviewsWithTargetSize(targetSize) {
            [weak self] (album: Album) in
            self?.presenter?.presentAlbumPreview(album)
        }
    }
}