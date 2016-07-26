import Foundation
import Photos
import DORateLimit

class PhotoLoader {
    private static let SmartCollections: [PHAssetCollectionSubtype] = [.SmartAlbumRecentlyAdded, .SmartAlbumPanoramas]
    // [.SmartAlbumGeneric, .SmartAlbumVideos, .SmartAlbumFavorites, .SmartAlbumTimelapses, .SmartAlbumAllHidden, .SmartAlbumBursts, .SmartAlbumSlomoVideos, .SmartAlbumUserLibrary, .SmartAlbumSelfPortraits, .SmartAlbumScreenshots
    private var albums = [String: PHFetchResult]()
    
    private var batchQueue = dispatch_queue_create("BatchQeuue", DISPATCH_QUEUE_SERIAL)
    private var imageResponses = [Int:SnapImagePickerImage]() // Only read and update from within batchQueue
}

extension PhotoLoader: ImageLoader {
    
    
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool = false, withPreviewSize previewSize: CGSize = CGSizeZero, handler: (SnapImagePickerImage) -> ()) -> PHImageRequestID {
        
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.synchronous = false
        options.deliveryMode = isPreview ? .Opportunistic : .HighQualityFormat
        
        let targetSize = isPreview ? previewSize : PHImageManagerMaximumSize
        let requestId = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: options) { (image, _) in
            
            if let image = image {
                let pickerImage = SnapImagePickerImage(image: image, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate)
                handler(pickerImage)
            }
        }
        return requestId
    }
    
    func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: ([Int: SnapImagePickerImage]) -> ()) {
        
        //TODO, should return a ([Int: SnapImagePickerImage]) -> ()
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.synchronous = false
        options.deliveryMode = .Opportunistic
        
        let imageManager = PHImageManager.defaultManager()
        for (index, asset) in assets {
            imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: options) {
                (image, _) in
                
                if let image = image {
                    let pickerImage = SnapImagePickerImage(image: image, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate)
                    self.batchImageResponses(pickerImage, index: index, handler: handler)
                }
            }
        }
    }
    
    private func batchImageResponses(pickerImage: SnapImagePickerImage, index: Int, handler: ([Int: SnapImagePickerImage]) -> ()) {
        
        dispatch_async(batchQueue) {
            if let existingImage = self.imageResponses[index] {
                if pickerImage.image.size.isSmallerThanOrEqualTo(existingImage.image.size) {
                    return
                }
                
                self.imageResponses[index] = pickerImage
            } else {
                self.imageResponses[index] = pickerImage
            }
        }
        
        RateLimit.throttle("batchImageResponses-throttle", threshold: 0.2, trailing: true) {
            dispatch_async(self.batchQueue) {
                let responses = self.imageResponses
                self.imageResponses = [Int:SnapImagePickerImage]()
                
                handler(responses)
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
    
    private func getFetchOptionsForCollection(type: AlbumType) -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        switch type {
        case .Favorites:
            options.predicate = NSPredicate(format: "favorite == YES") // TODO, not a format, but an expression
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
        collectionOptions.predicate = NSPredicate(format: "localizedTitle == \"\(title)\"") // TODO, not a format, but an expression
        
        let collections = PHAssetCollection.fetchAssetCollectionsWithType(type, subtype: .Any, options: collectionOptions)
        if collections.count > 0 {
            if let collection = collections.firstObject as? PHAssetCollection {
                return PHAsset.fetchAssetsInAssetCollection(collection, options: assetOptions)
            }
        }
        
        return nil
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAllPhotosPreview(targetSize: CGSize, handler: (Album) -> ()) {
        if let result = fetchAssetsFromCollectionWithType(.AllPhotos) {
            albums[AlbumType.AlbumNames.AllPhotos] = result
            createAlbumFromFetchResult(result, withType: .AllPhotos, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchFavoritesPreview(targetSize: CGSize, handler: (Album) -> ()) {
        if let result = fetchAssetsFromCollectionWithType(.Favorites) {
            albums[AlbumType.AlbumNames.Favorites] = result
            createAlbumFromFetchResult(result, withType: .Favorites, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchAllUserAlbumPreviews(targetSize: CGSize, handler: (Album) -> ()) {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0") // TODO, not a format, but an expression
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            [weak self] in
            
            
            if let strongSelf = self,
                let collection = $0.0 as? PHAssetCollection, // TODO: Reserve $0 for one-liners
                let title = collection.localizedTitle {
                
                let options = strongSelf.getFetchOptionsForCollection(.UserDefined(title: title))
                options.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)  // TODO: %i may not be what you want
                let result = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                
                if result.count > 0 {
                    strongSelf.albums[title] = result
                    strongSelf.createAlbumFromFetchResult(result, withType: .UserDefined(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    
    func fetchAllSmartAlbumPreviews(targetSize: CGSize, handler: (Album) -> ()) {
        for collection in PhotoLoader.SmartCollections {
            let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: collection, options: nil)
            if let collection = smartAlbums.firstObject as? PHAssetCollection,
               let title = collection.localizedTitle {
                
                let options = getFetchOptionsForCollection(.SmartAlbum(title: title))
                options.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue) // TODO: %i may not be what you want
                let result = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                
                if result.count > 0 {
                    albums[title] = result
                    createAlbumFromFetchResult(result, withType: .SmartAlbum(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    private func createAlbumFromFetchResult(fetchResult: PHFetchResult, withType type: AlbumType, previewImageTargetSize targetSize: CGSize, handler: (Album) -> ()) {
        if let asset = fetchResult.firstObject as? PHAsset {
            loadImageFromAsset(asset, isPreview: true, withPreviewSize: targetSize) {
                image in
                let newAlbum = Album(size: fetchResult.count, image: image.image, type: type)
                handler(newAlbum)
            }
        }
    }
}

extension CGSize {
    func isSmallerThanOrEqualTo(ref: CGSize) -> Bool {

        return self.width * self.height <= ref.width * ref.height
    }
}