import Photos

class AlbumSelectorEntityGateway {
    private weak var interactor: AlbumSelectorInteractorProtocol?
    
    enum CollectionNames {
        static let General = "Camera Roll"
        static let UserDefined = "User Defined"
    }
    
    init(interactor: AlbumSelectorInteractorProtocol) {
        self.interactor = interactor
    }
}

extension AlbumSelectorEntityGateway: AlbumSelectorEntityGatewayProtocol {
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: (String, Album) -> Void) {
        fetchAllPhotosPreview(targetSize, handler: handler)
        fetchFavoritesPreview(targetSize, handler: handler)
        fetchAllUserAlbumPreviews(targetSize, handler: handler)
    }
}

extension AlbumSelectorEntityGateway {
    private func fetchAllPhotosPreview(targetSize: CGSize, handler: (String, Album) -> Void) {
    if let result = PhotoLoader.fetchPhotosFromCollectionWithTitle(PhotoLoader.AlbumNames.AllPhotos) {
        AlbumSelectorEntityGateway.createAlbumFromFetchResult(result, withTitle: PhotoLoader.AlbumNames.AllPhotos, inCollection: CollectionNames.General, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    private func fetchFavoritesPreview(targetSize: CGSize, handler: (String, Album) -> Void) {
        if let result = PhotoLoader.fetchPhotosFromCollectionWithTitle(PhotoLoader.AlbumNames.Favorites) {
            AlbumSelectorEntityGateway.createAlbumFromFetchResult(result, withTitle: PhotoLoader.AlbumNames.Favorites, inCollection: CollectionNames.General, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    private func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: (String, Album) -> Void) {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            if let collection = $0.0 as? PHAssetCollection,
                let title = collection.localizedTitle {
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: onlyImagesOptions) {
                    AlbumSelectorEntityGateway.createAlbumFromFetchResult(result, withTitle: title, inCollection: CollectionNames.UserDefined, previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    private static func createAlbumFromFetchResult(fetchResult: PHFetchResult, withTitle title: String, inCollection collectionTitle: String, previewImageTargetSize targetSize: CGSize, handler: (String, Album) -> Void) {
        if let asset = fetchResult.firstObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
                (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    handler(collectionTitle, Album(title: title, size: fetchResult.count, image: image))
                }
            }
        }
    }
}