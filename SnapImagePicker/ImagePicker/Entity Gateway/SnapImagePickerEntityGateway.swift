import UIKit
import Photos

class SnapImagePickerEntityGateway {
    fileprivate weak var interactor: SnapImagePickerInteractorProtocol?
    weak var imageLoader: ImageLoaderProtocol?
    
    fileprivate var requests = [Int: PHImageRequestID]()
    
    init(interactor: SnapImagePickerInteractorProtocol, imageLoader: ImageLoaderProtocol?) {
        self.interactor = interactor
        self.imageLoader = imageLoader
    }
}

extension SnapImagePickerEntityGateway: SnapImagePickerEntityGatewayProtocol {
    func fetchAlbum(_ type: AlbumType) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) , fetchResult.count > 0,
           let asset = fetchResult.firstObject {
            let _ = imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSize.zero) {
                [weak self] (image: SnapImagePickerImage) in
                assert(Thread.isMainThread)
                self?.interactor?.loadedAlbum(type, withMainImage: image, albumSize: fetchResult.count)
            }
            
        }
    }
    
    fileprivate func loadAssetsFromAlbum(_ type: AlbumType, inRange range: CountableRange<Int>) -> [Int: PHAsset] {
        var assets = [Int: PHAsset]()
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            let start = max(range.lowerBound, 0)
            let end = min(range.endIndex, fetchResult.count)
            if start < end {
                for i in start..<end {
                    let asset = fetchResult.object(at: i)
                    assets[i] = asset
                }
            }
        }
        
        return assets
    }
    
    func fetchAlbumImagesFromAlbum(_ type: AlbumType, inRange range: CountableRange<Int>, withTargetSize targetSize: CGSize)  {
        let assets = loadAssetsFromAlbum(type, inRange: range)
        let fetchIds = imageLoader?.loadImagesFromAssets(assets, withTargetSize: targetSize) {
            [weak self] (results) in
            
            DispatchQueue.main.async {
                self?.interactor?.loadedAlbumImagesResult(results, fromAlbum: type)
            }
            
            if var tempRequests = self?.requests {
                for (index, _) in results {
                    tempRequests.removeValue(forKey: index)
                }
            
                self?.requests = tempRequests
            }
        }
        
        if let fetchIds = fetchIds {
            for (index, id) in fetchIds {
                requests[index] = id
            }
        }
    }
    
    func deleteImageRequestsInRange(_ range: CountableRange<Int>) {
        var requestIds = [PHImageRequestID]()
        for i in range {
            if let id = requests[i] {
                requestIds.append(id)
                requests[i] = nil
            }
        }
        
        imageLoader?.deleteRequests(requestIds)
    }
    
    func fetchMainImageFromAlbum(_ type: AlbumType, atIndex index: Int) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type),
               fetchResult.count > index {
            let asset = fetchResult.object(at: index)
            let _ = imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSize(width: SnapImagePickerTheme.maxImageSize, height: SnapImagePickerTheme.maxImageSize)) {
                [weak self] (image: SnapImagePickerImage) in
                
                DispatchQueue.main.async {
                    self?.interactor?.loadedMainImage(image, fromAlbum: type)
                }
                
            }
        }
    }
    
    func fetchImageWithLocalIdentifier(_ localIdentifier: String, fromAlbum type: AlbumType) {
        imageLoader?.loadImageWithLocalIdentifier(localIdentifier) {
            [weak self] (image) in
            DispatchQueue.main.async {
                self?.interactor?.loadedMainImage(image, fromAlbum: type)
            }
        }
    }
}
