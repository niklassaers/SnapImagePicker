import UIKit

class AlbumSelectorInteractor {
    fileprivate weak var presenter: AlbumSelectorPresenterProtocol?
    
    var entityGateway: AlbumSelectorEntityGatewayProtocol?
    
    init(presenter: AlbumSelectorPresenterProtocol) {
        self.presenter = presenter
    }
}

extension AlbumSelectorInteractor: AlbumSelectorInteractorProtocol {
    func fetchAlbumPreviewsWithTargetSize(_ targetSize: CGSize) {
        entityGateway?.fetchAlbumPreviewsWithTargetSize(targetSize) {
            [weak self] (album: Album) in
            self?.presenter?.presentAlbumPreview(album)
        }
    }
}
