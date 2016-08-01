import Photos
@testable import SnapImagePicker

class PhotoLoaderSpy {
    var loadImageFromAssetCount = 0
    var loadImageFromAssetAsset: PHAsset?
    var loadImageFromAssetIsPreview: Bool?
    var loadImageFromAssetPreviewSize: CGSize?
    var loadImageFromAssetHandler: (SnapImagePickerImage -> ())?
    
    var loadImageFromAssetsCount = 0
    var loadImageFromAssetsAssets: [Int: PHAsset]?
    var loadImageFromAssetsHandler: ([Int: SnapImagePickerImage] -> ())?
    
    var fetchAssetsFromCollectionWithTypeCount = 0
    var fetchAssetsFromCollectionWithTypeType: AlbumType?
    
    var fetchAllPhotosPreviewsCount = 0
    var fetchAllPhotosPreviewsTargetSize: CGSize?
    var fetchAllPhotosPreviewsHandler: (Album -> Void)?
    
    var fetchFavoritesPreviewsCount = 0
    var fetchFavoritesPreviewsTargetSize: CGSize?
    var fetchFavoritesPreviewsHandler: (Album -> Void)?
    
    var fetchUserAlbumPreviewsCount = 0
    var fetchUserAlbumPreviewsTargetSize: CGSize?
    var fetchUserAlbumPreviewsHandler: (Album -> Void)?
    
    var fetchSmartAlbumPreviewsCount = 0
    var fetchSmartAlbumPreviewsTargetSize: CGSize?
    var fetchSmartAlbumPreviewsHandler: (Album -> Void)?
}

extension PhotoLoaderSpy: ImageLoaderProtocol {
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> ()) -> PHImageRequestID {
        loadImageFromAssetCount += 1
        loadImageFromAssetAsset = asset
        loadImageFromAssetIsPreview = isPreview
        loadImageFromAssetPreviewSize = previewSize
        loadImageFromAssetHandler = handler
        
        return PHImageRequestID()
    }
    
    func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: ([Int: SnapImagePickerImage]) -> ()) {
        loadImageFromAssetsCount += 1
        loadImageFromAssetsAssets = assets
        loadImageFromAssetsHandler = handler
    }
    
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult? {
        fetchAssetsFromCollectionWithTypeCount += 1
        fetchAssetsFromCollectionWithTypeType = type
        
        return nil
    }
}

extension PhotoLoaderSpy: AlbumLoaderProtocol {
    func fetchAllPhotosPreview(targetSize: CGSize, handler: Album -> Void) {
        fetchAllPhotosPreviewsCount += 1
        fetchAllPhotosPreviewsTargetSize = targetSize
        fetchAllPhotosPreviewsHandler = handler
    }
    
    func fetchFavoritesPreview(targetSize: CGSize, handler: Album -> Void) {
        fetchFavoritesPreviewsCount += 1
        fetchFavoritesPreviewsTargetSize = targetSize
        fetchFavoritesPreviewsHandler = handler
    }
    
    func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: Album -> Void) {
        fetchUserAlbumPreviewsCount += 1
        fetchUserAlbumPreviewsTargetSize = targetSize
        fetchUserAlbumPreviewsHandler = handler
    }
    
    func fetchAllSmartAlbumPreviews(targetSize: CGSize, handler: Album -> Void) {
        fetchSmartAlbumPreviewsCount += 1
        fetchSmartAlbumPreviewsTargetSize = targetSize
        fetchSmartAlbumPreviewsHandler = handler
    }
}