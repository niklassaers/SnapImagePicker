import Foundation
import Photos

protocol AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void)
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void)
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: PhotoAlbum -> Void)
}

class PhotoLoader {
    
    struct DefaultAlbumNames {
        static let AllPhotos = "Album"
        static let Favorites = "Favorites"
    }
    
    private enum AlbumType {
        case AllPhotos
        case Favorites
        case UserDefined(name: String)
        
        static func fromTitle(title: String) -> AlbumType {
            switch title {
            case DefaultAlbumNames.AllPhotos: return .AllPhotos
            case DefaultAlbumNames.Favorites: return .Favorites
            default: return .UserDefined(name: title)
            }
        }
    }
}

extension PhotoLoader {
    private func fetchPhotosFromCollectionWithTitle(title: String) -> PHFetchResult? {
        let type = AlbumType.fromTitle(title)
        let options = getFetchOptionsForCollection(type)
        
        switch type {
        case .AllPhotos: fallthrough
        case .Favorites:
            return fetchPhotosWithOptions(options)
        case .UserDefined(title):
            return fetchUserDefinedCollectionWithTitle(title, options: options)
        default: break // Why are not all cases handled?
        }
        
        return nil
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
    
    private func fetchPhotosWithOptions(options: PHFetchOptions? = nil) -> PHFetchResult {
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
    
    private func fetchUserDefinedCollectionWithTitle(title: String, options: PHFetchOptions?) -> PHFetchResult? {
        let collectionOptions = PHFetchOptions()
        collectionOptions.predicate = NSPredicate(format: "localizedTitle == \"\(title)\"")
        let collections = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: collectionOptions)
        if collections.count > 0 {
            if let collection = collections.firstObject as? PHAssetCollection {
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: options) {
                    return result
                }
            }
        }
        
        return nil
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        if let fetchResult = fetchPhotosFromCollectionWithTitle(albumTitle) {
            fetchResult.enumerateObjectsUsingBlock { (object: AnyObject, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let asset = object as? PHAsset {
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
                        (image: UIImage?, data: [NSObject : AnyObject]?) in
                        if let image = image {
                            handler(image, asset.localIdentifier)
                        }
                    }
                }
            }
        }
    }
    
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([id], options: nil)
        if let asset = fetchResult.firstObject as? PHAsset{
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(width: 2000, height: 2000), contentMode: .Default, options: nil) {
                (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    handler(image, asset.localIdentifier)
                }
            }
        }
    }
    
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        fetchAllPhotosPreview(targetSize, handler: handler)
        fetchFavoritesPreview(targetSize, handler: handler)
        fetchAllUserAlbumPreviews(targetSize, handler: handler)
    }
}
extension PhotoLoader {

    private func fetchAllPhotosPreview(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        if let result = fetchPhotosFromCollectionWithTitle(DefaultAlbumNames.AllPhotos) {
            PhotoLoader.createPhotoAlbumFromFetchResult(result, withTitle: DefaultAlbumNames.AllPhotos, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    private func fetchFavoritesPreview(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        if let result = fetchPhotosFromCollectionWithTitle(DefaultAlbumNames.Favorites) {
            PhotoLoader.createPhotoAlbumFromFetchResult(result, withTitle: DefaultAlbumNames.Favorites, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    private func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            if let collection = $0.0 as? PHAssetCollection,
                let title = collection.localizedTitle {
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: onlyImagesOptions) {
                    PhotoLoader.createPhotoAlbumFromFetchResult(result, withTitle: title, previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    private static func createPhotoAlbumFromFetchResult(fetchResult: PHFetchResult, withTitle title: String, previewImageTargetSize targetSize: CGSize, handler: PhotoAlbum -> Void) {
        if let asset = fetchResult.firstObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
                (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    handler(PhotoAlbum(title: title, size: fetchResult.count, image: image))
                }
            }
        }
    }
}