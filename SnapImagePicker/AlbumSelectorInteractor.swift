import Foundation

class AlbumSelectorInteractor {
    private weak var presenter: AlbumSelectorPresenterProtocol?
    private var entityGateway: AlbumSelectorEntityGatewayProtocol?
    
    init(presenter: AlbumSelectorPresenterProtocol) {
        self.presenter = presenter
        entityGateway = AlbumSelectorEntityGateway(interactor: self)
    }
}

extension AlbumSelectorInteractor: AlbumSelectorInteractorProtocol {

}