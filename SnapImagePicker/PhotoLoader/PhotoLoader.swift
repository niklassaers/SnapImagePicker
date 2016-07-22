import Foundation
import Photos

class PhotoLoader {
    private static let SmartCollections: [PHAssetCollectionSubtype] = [.SmartAlbumRecentlyAdded, .SmartAlbumPanoramas]
    // [.SmartAlbumGeneric, .SmartAlbumVideos, .SmartAlbumFavorites, .SmartAlbumTimelapses, .SmartAlbumAllHidden, .SmartAlbumBursts, .SmartAlbumSlomoVideos, .SmartAlbumUserLibrary, .SmartAlbumSelfPortraits, .SmartAlbumScreenshots
    private var albums = [String: PHFetchResult]()
}

extension PhotoLoader: ImageLoader {
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool = false, withPreviewSize previewSize: CGSize = CGSizeZero, handler: (SnapImagePickerImage) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = false
        options.synchronous = false
        options.deliveryMode = isPreview ? .Opportunistic : .HighQualityFormat
        let targetSize = isPreview ? previewSize : PHImageManagerMaximumSize
        let requestId = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: options) {
            (image: UIImage?, data: [NSObject : AnyObject]?) in
            if let image = image {
                handler(SnapImagePickerImage(image: image, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate))
            }
        }
        return requestId
    }
    
    func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: (SnapImagePickerImage, Int) -> Void) {
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = false
        options.synchronous = false
        options.deliveryMode = .Opportunistic
        
        let imageManager = PHImageManager.defaultManager()
        for (index, asset) in assets {
            imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: options) {
                (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    handler(SnapImagePickerImage(image: image, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate), index)
                }
            }
        }
    }
    
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult? {
        if let album = albums[type.getAlbumName()] {
            return album
        }
        let options = getFetchOptionsForCollection(type)
        
        switch type {
        case .AllPhotos:
            fallthrough
        case .Favorites:
            return fetchPhotosWithOptions(options)
        case .UserDefined(let title):
            return fetchUserDefinedCollectionWithTitle(title, withOptions: options)
        case .SmartAlbum(let title):
            return fetchSmartAlbumWithTitle(title, withOptions: options)
        }
    }
    
    func deleteRequestForId(id: PHImageRequestID) {
        PHImageManager.defaultManager().cancelImageRequest(id)
    }
    
    func clearPendingRequests() {

    }
    
    private func getFetchOptionsForCollection(type: AlbumType) -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        switch type {
        case .Favorites: options.predicate = NSPredicate(format: "favorite == YES")
        case .SmartAlbum(let title):
            if title == "Recently Added" {
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            }
        default: break
        }
        
        return options
    }
    
    private func fetchPhotosWithOptions(options: PHFetchOptions?) -> PHFetchResult {
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
    
    private func fetchUserDefinedCollectionWithTitle(title: String, withOptions options: PHFetchOptions?) -> PHFetchResult? {
        return fetchCollectionWithTitle(title, withType: .Album, andAssetOptions: options)
    }
    
    private func fetchSmartAlbumWithTitle(title: String, withOptions options: PHFetchOptions?) -> PHFetchResult? {
        return fetchCollectionWithTitle(title, withType: .SmartAlbum, andAssetOptions: options)
    }
    
    private func fetchCollectionWithTitle(title: String, withType type: PHAssetCollectionType, andAssetOptions assetOptions: PHFetchOptions?) -> PHFetchResult? {
        let collectionOptions = PHFetchOptions()
        collectionOptions.predicate = NSPredicate(format: "localizedTitle == \"\(title)\"")
        
        let collections = PHAssetCollection.fetchAssetCollectionsWithType(type, subtype: PHAssetCollectionSubtype.Any, options: collectionOptions)
        if collections.count > 0 {
            if let collection = collections.firstObject as? PHAssetCollection {
                return PHAsset.fetchAssetsInAssetCollection(collection, options: assetOptions)
            }
        }
        
        return nil
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAllPhotosPreview(targetSize: CGSize, handler: Album -> Void) {
        if let result = fetchAssetsFromCollectionWithType(AlbumType.AllPhotos) {
            albums[AlbumType.AlbumNames.AllPhotos] = result
            createAlbumFromFetchResult(result, withType: AlbumType.AllPhotos, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchFavoritesPreview(targetSize: CGSize, handler: Album -> Void) {
        if let result = fetchAssetsFromCollectionWithType(AlbumType.Favorites) {
            albums[AlbumType.AlbumNames.Favorites] = result
            createAlbumFromFetchResult(result, withType: AlbumType.Favorites, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: Album -> Void) {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            [weak self] in
            if let collection = $0.0 as? PHAssetCollection,
               let title = collection.localizedTitle,
               let options = self?.getFetchOptionsForCollection(AlbumType.UserDefined(title: title)){
                options.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                let result = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                if result.count > 0 {
                    self?.albums[title] = result
                    self?.createAlbumFromFetchResult(result, withType: AlbumType.UserDefined(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    
    func fetchAllSmartAlbumPreviews(targetSize: CGSize, handler: Album -> Void) {
        for collection in PhotoLoader.SmartCollections {
            let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: collection, options: nil)
            if let collection = smartAlbums.firstObject as? PHAssetCollection,
               let title = collection.localizedTitle {
                let options = getFetchOptionsForCollection(AlbumType.SmartAlbum(title: title))
                options.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                let result = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                if result.count > 0 {
                    albums[title] = result
                    createAlbumFromFetchResult(result, withType: AlbumType.SmartAlbum(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    private func createAlbumFromFetchResult(fetchResult: PHFetchResult, withType type: AlbumType, previewImageTargetSize targetSize: CGSize, handler: Album -> Void) {
        if let asset = fetchResult.firstObject as? PHAsset {
            loadImageFromAsset(asset, isPreview: true, withPreviewSize: targetSize) {
                (image: SnapImagePickerImage) in
                handler(Album(size: fetchResult.count, image: image.image, type: type))
            }
        }
    }
}