import Photos

class AlbumSelectorEntityGateway {
    private weak var interactor: AlbumSelectorInteractorProtocol?
    weak var albumLoader: AlbumLoaderProtocol?
    
    init(interactor: AlbumSelectorInteractorProtocol, albumLoader: AlbumLoaderProtocol?) {
        self.interactor = interactor
        self.albumLoader = albumLoader
    }
}

extension AlbumSelectorEntityGateway: AlbumSelectorEntityGatewayProtocol {
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: Album -> Void) {
        albumLoader?.fetchAllPhotosPreview(targetSize, handler: handler)
        albumLoader?.fetchFavoritesPreview(targetSize, handler: handler)
        albumLoader?.fetchAllUserAlbumPreviews(targetSize, handler: handler)
        albumLoader?.fetchAllSmartAlbumPreviews(targetSize, handler: handler)
    }
}