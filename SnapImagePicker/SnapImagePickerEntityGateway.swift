import Foundation
import Photos

class SnapImagePickerEntityGateway {
    private weak var interactor: SnapImagePickerInteractorProtocol?
    
    struct AlbumNames {
        static let AllPhotos = "Album"
        static let Favorites = "Favorites"
    }
    
    private enum AlbumType {
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
    
    init(interactor: SnapImagePickerInteractorProtocol) {
        self.interactor = interactor
    }
}
extension SnapImagePickerEntityGateway {
    private func loadImageFromAsset(asset: PHAsset, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
            (image: UIImage?, data: [NSObject : AnyObject]?) in
            if let image = image {
                handler(image, asset.localIdentifier)
            }
        }
    }
    
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

extension SnapImagePickerEntityGateway: SnapImagePickerEntityGatewayProtocol {
    func loadAlbumWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        if let fetchResult = fetchPhotosFromCollectionWithTitle(localIdentifier) {
            fetchResult.enumerateObjectsUsingBlock { (object: AnyObject, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let asset = object as? PHAsset {
                    self.loadImageFromAsset(asset, withTargetSize: targetSize) {
                        [weak self] (image: UIImage?, id: String) in
                        if let image = image {
                            self?.interactor?.loadedAlbumImage(image, localIdentifier: id)
                        }
                    }
                }
            }
        }
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)
        if let asset = fetchResult.firstObject as? PHAsset{
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(width: 2000, height: 2000), contentMode: .Default, options: nil) {
                [weak self] (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    self?.interactor?.loadedMainImage(image)
                }
            }
        }
    }
}