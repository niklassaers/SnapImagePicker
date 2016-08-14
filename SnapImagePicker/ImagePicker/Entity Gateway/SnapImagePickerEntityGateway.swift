import UIKit
import Photos

class SnapImagePickerEntityGateway {
    private weak var interactor: SnapImagePickerInteractorProtocol?
    weak var imageLoader: ImageLoaderProtocol?
    
    private var requests = [Int: PHImageRequestID]()
    
    init(interactor: SnapImagePickerInteractorProtocol, imageLoader: ImageLoaderProtocol?) {
        self.interactor = interactor
        self.imageLoader = imageLoader
    }
}

extension SnapImagePickerEntityGateway: SnapImagePickerEntityGatewayProtocol {
    func fetchAlbum(type: AlbumType) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) where fetchResult.count > 0,
           let asset = fetchResult.firstObject as? PHAsset {
            imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSizeZero) {
                [weak self] (image: SnapImagePickerImage) in
                assert(NSThread.isMainThread())
                self?.interactor?.loadedAlbum(type, withMainImage: image, albumSize: fetchResult.count)
            }
            
        }
    }
    
    private func loadAssetsFromAlbum(type: AlbumType, inRange range: Range<Int>) -> [Int: PHAsset] {
        var assets = [Int: PHAsset]()
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            let start = max(range.startIndex, 0)
            let end = min(range.endIndex, fetchResult.count)
            if start < end {
                for i in start..<end {
                    if let asset = fetchResult.objectAtIndex(i) as? PHAsset {
                        assets[i] = asset
                    }
                }
            }
        }
        
        return assets
    }
    
    func fetchAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>, withTargetSize targetSize: CGSize)  {
        let assets = loadAssetsFromAlbum(type, inRange: range)
        let fetchIds = imageLoader?.loadImagesFromAssets(assets, withTargetSize: targetSize) {
            [weak self] (results) in
            
            dispatch_async(dispatch_get_main_queue()) {
                self?.interactor?.loadedAlbumImagesResult(results, fromAlbum: type)
            }
            for (index, _) in results {
                self?.requests[index] = nil
            }
        }
        
        if let fetchIds = fetchIds {
            for (index, id) in fetchIds {
                requests[index] = id
            }
        }
    }
    
    func deleteImageRequestsInRange(range: Range<Int>) {
        var requestIds = [PHImageRequestID]()
        for i in range {
            if let id = requests[i] {
                requestIds.append(id)
                requests[i] = nil
            }
        }
        
        imageLoader?.deleteRequests(requestIds)
    }
    
    func fetchMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type)
            where fetchResult.count > index {
            if let asset = fetchResult.objectAtIndex(index) as? PHAsset {
                imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSize(width: SnapImagePickerTheme.maxImageSize, height: SnapImagePickerTheme.maxImageSize)) {
                    [weak self] (image: SnapImagePickerImage) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.interactor?.loadedMainImage(image, fromAlbum: type)
                    }
                }
            }
        }
    }
    
    func fetchImageWithLocalIdentifier(localIdentifier: String, fromAlbum type: AlbumType) {
        imageLoader?.loadImageWithLocalIdentifier(localIdentifier) {
            [weak self] (image) in
            dispatch_async(dispatch_get_main_queue()) {
                self?.interactor?.loadedMainImage(image, fromAlbum: type)
            }
        }
    }
}