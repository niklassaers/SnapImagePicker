class AlbumSelectorEntityGateway {
    private weak var interactor: AlbumSelectorInteractorProtocol?
    
    init(interactor: AlbumSelectorInteractorProtocol) {
        self.interactor = interactor
    }
}

extension AlbumSelectorEntityGateway: AlbumSelectorEntityGatewayProtocol {
    
}