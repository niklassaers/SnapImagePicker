import Photos

class AlbumSelectorEntityGateway {
    fileprivate weak var interactor: AlbumSelectorInteractorProtocol?
    weak var albumLoader: AlbumLoaderProtocol?
    
    init(interactor: AlbumSelectorInteractorProtocol, albumLoader: AlbumLoaderProtocol?) {
        self.interactor = interactor
        self.albumLoader = albumLoader
    }
}

extension AlbumSelectorEntityGateway: AlbumSelectorEntityGatewayProtocol {
    func fetchAlbumPreviewsWithTargetSize(_ targetSize: CGSize, handler: @escaping (Album) -> Void) {
        albumLoader?.fetchAllPhotosPreview(targetSize, handler: handler)
        albumLoader?.fetchFavoritesPreview(targetSize, handler: handler)
        albumLoader?.fetchAllUserAlbumPreviews(targetSize, handler: handler)
        albumLoader?.fetchAllSmartAlbumPreviews(targetSize, handler: handler)
    }
}
