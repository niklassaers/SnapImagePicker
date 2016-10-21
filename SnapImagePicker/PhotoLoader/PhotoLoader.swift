import Foundation
import Photos
import DORateLimit

class PhotoLoader {
    fileprivate static let SmartCollections: [PHAssetCollectionSubtype] = [.smartAlbumRecentlyAdded, .smartAlbumPanoramas]
    // [.SmartAlbumGeneric, .SmartAlbumVideos, .SmartAlbumFavorites, .SmartAlbumTimelapses, .SmartAlbumAllHidden, .SmartAlbumBursts, .SmartAlbumSlomoVideos, .SmartAlbumUserLibrary, .SmartAlbumSelfPortraits, .SmartAlbumScreenshots
    fileprivate var albums = [String: PHFetchResult<PHAsset>]()
    
    fileprivate var batchQueue = DispatchQueue(label: "BatchQeuue", attributes: [])
    fileprivate var imageResponses = [Int:SnapImagePickerImage]() // Only read and update from within batchQueue
}

extension PhotoLoader: ImageLoaderProtocol {
    
    func loadImageFromAsset(_ asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize, handler: @escaping (SnapImagePickerImage) -> ()) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.deliveryMode = isPreview ? .opportunistic : .highQualityFormat
        
        let targetSize = isPreview ? previewSize : PHImageManagerMaximumSize
        let requestId = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options) { (image, _) in
            
            if let image = image {
                let pickerImage = SnapImagePickerImage(image: image, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate)
                handler(pickerImage)
            }
        }
        return requestId
    }
    
    func deleteRequests(_ requestIds: [PHImageRequestID]) {
        let imageManager = PHImageManager.default()
        for id in requestIds {
            imageManager.cancelImageRequest(id)
        }
    }
    
    func loadImagesFromAssets(_ assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: @escaping ([Int: SnapImagePickerImage]) -> ()) -> [Int: PHImageRequestID] {
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let imageManager = PHImageManager.default()
        var fetchIds = [Int: PHImageRequestID]()
        for (index, asset) in assets {
            let fetchId = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) {
                (image, _) in
                if let image = image,
                   let squaredImage = image.square() {
                    let pickerImage = SnapImagePickerImage(image: squaredImage, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate)
                    self.batchImageResponses(pickerImage, index: index, handler: handler)
                }
            }
            fetchIds[index] = fetchId
        }
        
        return fetchIds
    }
    
    fileprivate func batchImageResponses(_ pickerImage: SnapImagePickerImage, index: Int, handler: @escaping ([Int: SnapImagePickerImage]) -> ()) {
        
        batchQueue.async {
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
            [weak self] in
            if let strongSelf = self {
                strongSelf.batchQueue.async {
                    [weak self] in
                    let responses = self?.imageResponses
                    self?.imageResponses = [Int:SnapImagePickerImage]()
                    
                    if let responses = responses {
                        handler(responses)
                    }
                }
            }
        }
    }
    
    func fetchAssetsFromCollectionWithType(_ type: AlbumType) -> PHFetchResult<PHAsset>? {
        if let album = albums[type.getAlbumName()] {
            return album
        }
        let options = getFetchOptionsForCollection(type)
        
        switch type {
        case .allPhotos:
            fallthrough
        case .favorites:
            return fetchPhotosWithOptions(options)
        case .userDefined(let title):
            return fetchUserDefinedCollectionWithTitle(title, withOptions: options)
        case .smartAlbum(let title):
            return fetchSmartAlbumWithTitle(title, withOptions: options)
        }
    }
    
    fileprivate func getFetchOptionsForCollection(_ type: AlbumType) -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        switch type {
        case .favorites:
            options.predicate = NSPredicate(format: "favorite == YES") // TODO, not a format, but an expression
        case .smartAlbum(let title):
            if title == "Recently Added" {
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            }
        default: break
        }
        
        return options
    }
    
    fileprivate func fetchPhotosWithOptions(_ options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: .image, options: options)
    }
    
    fileprivate func fetchUserDefinedCollectionWithTitle(_ title: String, withOptions options: PHFetchOptions?) -> PHFetchResult<PHAsset>? {
        return fetchCollectionWithTitle(title, withType: .album, andAssetOptions: options)
    }
    
    fileprivate func fetchSmartAlbumWithTitle(_ title: String, withOptions options: PHFetchOptions?) -> PHFetchResult<PHAsset>? {
        return fetchCollectionWithTitle(title, withType: .smartAlbum, andAssetOptions: options)
    }
    
    fileprivate func fetchCollectionWithTitle(_ title: String, withType type: PHAssetCollectionType, andAssetOptions assetOptions: PHFetchOptions?) -> PHFetchResult<PHAsset>? {
        let collectionOptions = PHFetchOptions()
        collectionOptions.predicate = NSPredicate(format: "localizedTitle == \"\(title)\"") // TODO, not a format, but an expression
        
        let collections = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: collectionOptions)
        if collections.count > 0 {
            if let collection = collections.firstObject {
                return PHAsset.fetchAssets(in: collection, options: assetOptions)
            }
        }
        
        return nil
    }
    
    func loadImageWithLocalIdentifier(_ identifier: String, handler: @escaping ((SnapImagePickerImage) -> Void)) {
        let assetOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: assetOptions)
        if let asset = assets.firstObject {
            let targetSize = CGSize(width: SnapImagePickerTheme.maxImageSize, height: SnapImagePickerTheme.maxImageSize)
            
            let imageOptions = PHImageRequestOptions()
            imageOptions.isNetworkAccessAllowed = true
            imageOptions.isSynchronous = false
            imageOptions.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions) {
                (image, _) in
                
                if let image = image {
                    let pickerImage = SnapImagePickerImage(image: image, localIdentifier: asset.localIdentifier, createdDate: asset.creationDate)
                    handler(pickerImage)
                }
            }
        }
    }
}

extension PhotoLoader: AlbumLoaderProtocol {
    func fetchAllPhotosPreview(_ targetSize: CGSize, handler: @escaping (Album) -> ()) {
        if let result = fetchAssetsFromCollectionWithType(.allPhotos) {
            albums[AlbumType.AlbumNames.AllPhotos] = result
            createAlbumFromFetchResult(result, withType: .allPhotos, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchFavoritesPreview(_ targetSize: CGSize, handler: @escaping (Album) -> ()) {
        if let result = fetchAssetsFromCollectionWithType(.favorites) {
            albums[AlbumType.AlbumNames.Favorites] = result
            createAlbumFromFetchResult(result, withType: .favorites, previewImageTargetSize: targetSize, handler: handler)
        }
    }
    
    func fetchAllUserAlbumPreviews(_ targetSize: CGSize, handler: @escaping (Album) -> ()) {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0") // TODO, not a format, but an expression
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: userAlbumsOptions)
        
        
        userAlbums.enumerateObjects({
            [weak self] (collection: PHAssetCollection, _: Int, _: UnsafeMutablePointer<ObjCBool>) in
            
            
            if let strongSelf = self,
               let title = collection.localizedTitle {
                
                let options = strongSelf.getFetchOptionsForCollection(.userDefined(title: title))
                options.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)")  // TODO: Same as above
                let result = PHAsset.fetchAssets(in: collection, options: options)
                
                if result.count > 0 {
                    strongSelf.albums[title] = result
                    strongSelf.createAlbumFromFetchResult(result, withType: .userDefined(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        })
    }
    
    
    func fetchAllSmartAlbumPreviews(_ targetSize: CGSize, handler: @escaping (Album) -> ()) {
        for collection in PhotoLoader.SmartCollections {
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: collection, options: nil)
            if let collection = smartAlbums.firstObject,
               let title = collection.localizedTitle {
                
                let options = getFetchOptionsForCollection(.smartAlbum(title: title))
                options.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)") // TODO: Same as above
                let result = PHAsset.fetchAssets(in: collection, options: options)
                
                if result.count > 0 {
                    albums[title] = result
                    createAlbumFromFetchResult(result, withType: .smartAlbum(title: title), previewImageTargetSize: targetSize, handler: handler)
                }
            }
        }
    }
    
    fileprivate func createAlbumFromFetchResult(_ fetchResult: PHFetchResult<PHAsset>, withType type: AlbumType, previewImageTargetSize targetSize: CGSize, handler: @escaping (Album) -> ()) {
        if let asset = fetchResult.firstObject {
            let _ = loadImageFromAsset(asset, isPreview: true, withPreviewSize: targetSize) {
                image in
                let newAlbum = Album(size: fetchResult.count, image: image.image, type: type)
                handler(newAlbum)
            }
        }
    }
}

extension CGSize {
    func isSmallerThanOrEqualTo(_ ref: CGSize) -> Bool {

        return self.width * self.height <= ref.width * ref.height
    }
}
