import Foundation
import Photos

class PhotoLoader {
    struct AlbumNames {
        static let AllPhotos = "Album"
        static let Favorites = "Favorites"
    }
    
    enum AlbumType {
        case AllPhotos
        case Favorites
        case UserDefined(title: String)
        
        static func fromTitle(title: String) -> AlbumType {
            switch title {
            case AlbumNames.AllPhotos: return .AllPhotos
            case AlbumNames.Favorites: return .Favorites
            default: return UserDefined(title: title)
            }
        }
    }
    
    static func fetchPhotosFromCollectionWithTitle(title: String) -> PHFetchResult? {
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
    
    private static func getFetchOptionsForCollection(type: AlbumType) -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        switch type {
        case .Favorites: options.predicate = NSPredicate(format: "favorite == YES")
        default: break
        }
        
        return options
    }
    
    private static func fetchPhotosWithOptions(options: PHFetchOptions? = nil) -> PHFetchResult {
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
    
    private static func fetchUserDefinedCollectionWithTitle(title: String, options: PHFetchOptions?) -> PHFetchResult? {
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