import Foundation
import Photos

class PhotoLoader {
    private static let SmartCollections = ["Recently Added", "Selfies", "Panoramas"]
    private var albums = [String: PHFetchResult]()
}

extension PhotoLoader: ImageLoader {
    func fetchPhotosFromCollectionWithType(type: AlbumType) -> PHFetchResult? {
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
            return fetchUserDefinedCollectionWithTitle(title, options: options)
        case .SmartAlbum(let title):
            return fetchSmartAlbumWithTitle(title, options: options)
        }
    }
    
    private func getFetchOptionsForCollection(type: AlbumType) -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        switch type {
        case .Favorites: options.predicate = NSPredicate(format: "favorite == YES")
        default: break
        }
        
        return options
    }
    
    private func fetchPhotosWithOptions(options: PHFetchOptions?) -> PHFetchResult {
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
    
    private func fetchUserDefinedCollectionWithTitle(title: String, options: PHFetchOptions?) -> PHFetchResult? {
        return fetchCollectionWithTitle(title, withType: .Album, andAssetOptions: options)
    }
    
    private func fetchSmartAlbumWithTitle(title: String, options: PHFetchOptions?) -> PHFetchResult? {
        return fetchCollectionWithTitle(title, withType: .SmartAlbum, andAssetOptions: options)
    }
    
    private func fetchCollectionWithTitle(title: String, withType type: PHAssetCollectionType, andAssetOptions assetOptions: PHFetchOptions?) -> PHFetchResult? {
        let collectionOptions = PHFetchOptions()
        collectionOptions.predicate = NSPredicate(format: "localizedTitle == \"\(title)\"")
        
        let collections = PHAssetCollection.fetchAssetCollectionsWithType(type, subtype: PHAssetCollectionSubtype.Any, options: collectionOptions)
        if collections.count > 0 {
            if let collection = collections.firstObject as? PHAssetCollection {
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: assetOptions) {
                    return result
                }
            }
        }
        
        return nil
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAllPhotosPreview(targetSize: CGSize, handler: Album -> Void) {
        if let result = fetchPhotosFromCollectionWithType(AlbumType.AllPhotos) {
            albums[AlbumType.AlbumNames.AllPhotos] = result
            PhotoLoader.createAlbumFromFetchResult(result, withType: AlbumType.AllPhotos, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchFavoritesPreview(targetSize: CGSize, handler: Album -> Void) {
        if let result = fetchPhotosFromCollectionWithType(AlbumType.Favorites) {
            albums[AlbumType.AlbumNames.Favorites] = result
            PhotoLoader.createAlbumFromFetchResult(result, withType: AlbumType.Favorites, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: Album -> Void) {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            [weak self] in
            if let collection = $0.0 as? PHAssetCollection,
                let title = collection.localizedTitle {
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: onlyImagesOptions) {
                    self?.albums[title] = result
                    PhotoLoader.createAlbumFromFetchResult(result, withType: AlbumType.UserDefined(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    
    func fetchAllSmartAlbumPreviews(targetSize: CGSize, handler: Album -> Void) {
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
        smartAlbums.enumerateObjectsUsingBlock() {
            [weak self] (element: AnyObject, index: Int, _: UnsafeMutablePointer<ObjCBool>) in print("Heii")
            
            if let collection = element as? PHAssetCollection,
                let title = collection.localizedTitle
                where PhotoLoader.SmartCollections.contains(title) {
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: onlyImagesOptions)
                    where result.count > 0 {
                    self?.albums[title] = result
                    PhotoLoader.createAlbumFromFetchResult(result, withType: AlbumType.SmartAlbum(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    private static func createAlbumFromFetchResult(fetchResult: PHFetchResult, withType type: AlbumType, previewImageTargetSize targetSize: CGSize, handler: Album -> Void) {
        if let asset = fetchResult.firstObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
                (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    handler(Album(size: fetchResult.count, image: image, type: type))
                }
            }
        }
    }
}