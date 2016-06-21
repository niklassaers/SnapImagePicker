import Foundation
import Photos

protocol AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void)
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void)
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: PhotoAlbum -> Void)
}

class PhotoLoader {
    
    struct AlbumNames {
        static let AllPhotos = "Album"
        static let Favorites = "Favorites"
    }
    
    private enum AlbumType {
        case AllPhotos
        case Favorites
        case Custom(name: String)
        
        static func fromTitle(title: String) -> AlbumType {
            switch title {
            case AlbumNames.AllPhotos: return .AllPhotos
            case AlbumNames.Favorites: return .Favorites
            default: return .Custom(name: title)
            }
        }
    }
}

extension PhotoLoader {
    private func getFetchResultForAlbum(title: String) -> PHFetchResult? {
        return fetchPhotosFromCollectionWithTitle(title)
    }
    
    private func getFetchOptionsForCollection(title: String) -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let type = AlbumType.fromTitle(title)
        switch type {
        case .Favorites: options.predicate = NSPredicate(format: "favorite == YES")
        case .Custom(title): options.predicate = NSPredicate(format: "localIdentifier == \"\(title)\"")
        default: break
        }

        return options
    }
    
    private func fetchPhotosFromCollectionWithTitle(title: String) -> PHFetchResult {
        let options = getFetchOptionsForCollection(title)
        return fetchPhotosFromCollectionWithTitle(title, withOptions: options)
    }
    
    private func fetchPhotosFromCollectionWithTitle(title: String, withOptions options: PHFetchOptions) -> PHFetchResult {
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        if let fetchResult = getFetchResultForAlbum(albumTitle) {
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
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
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
    
    private func fetchAllPhotosPreview(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        if let result = getFetchResultForAlbum(AlbumNames.AllPhotos) {
            PhotoLoader.createPhotoAlbum(AlbumNames.AllPhotos, fetchResult: result, targetSize: targetSize, handler: handler)
        }
    }
    
    private func fetchFavoritesPreview(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        if let result = getFetchResultForAlbum(AlbumNames.Favorites) {
            PhotoLoader.createPhotoAlbum(AlbumNames.Favorites, fetchResult: result, targetSize: targetSize, handler: handler)
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
                    PhotoLoader.createPhotoAlbum(title, fetchResult: result, targetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    private static func createPhotoAlbum(title: String, fetchResult: PHFetchResult, targetSize: CGSize, handler: PhotoAlbum -> Void) {
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