import UIKit
import Photos

class SnapImagePickerEntityGateway {
    private weak var interactor: SnapImagePickerInteractorProtocol?
    private weak var imageLoader: ImageLoader?
    
    init(interactor: SnapImagePickerInteractorProtocol, imageLoader: ImageLoader?) {
        self.interactor = interactor
        self.imageLoader = imageLoader
    }
}

extension SnapImagePickerEntityGateway: SnapImagePickerEntityGatewayProtocol {
    func fetchAlbum(type: AlbumType) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            if let asset = fetchResult.firstObject as? PHAsset {
                imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSizeZero) {
                    [weak self] (image: SnapImagePickerImage) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.interactor?.loadedAlbum(image, albumSize: fetchResult.count)
                    }
                }
            }
        }
    }
    
    func fetchAlbumImageFromAlbum(type: AlbumType, atIndex index: Int) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type)
        where fetchResult.count > index {
            if let asset = fetchResult.objectAtIndex(index) as? PHAsset {
                imageLoader?.loadImageFromAsset(asset, isPreview: true, withPreviewSize: CGSize(width: 150, height: 150)) {
                    [weak self] (image: SnapImagePickerImage) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.interactor?.loadedAlbumImage(image, fromAlbum: type, atIndex: index)
                    }
                }
            }
        }
    }
    
    private func loadAssetsFromAlbum(type: AlbumType, inRange range: Range<Int>) -> [Int: PHAsset] {
        var assets = [Int: PHAsset]()
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            for i in max(range.startIndex, 0)..<min(range.endIndex, fetchResult.count) {
                if let asset = fetchResult.objectAtIndex(i) as? PHAsset {
                    assets[i] = asset
                }
            }
        }
        
        return assets
    }
    
    func fetchAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>)  {
        let assets = loadAssetsFromAlbum(type, inRange: range)
        imageLoader?.loadImagesFromAssets(assets, withTargetSize: CGSize(width: 150, height: 150)) {
            [weak self] (image: SnapImagePickerImage, index: Int) in
            dispatch_async(dispatch_get_main_queue()) {
                self?.interactor?.loadedAlbumImage(image, fromAlbum: type, atIndex: index)
            }
        }
    }
    
    func fetchMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type)
            where fetchResult.count > index {
            if let asset = fetchResult.objectAtIndex(index) as? PHAsset {
                imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSize(width: SnapImagePicker.Theme.maxImageSize, height: SnapImagePicker.Theme.maxImageSize)) {
                    [weak self] (image: SnapImagePickerImage) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.interactor?.loadedMainImage(image, fromAlbum: type)
                    }
                }
            }
        }
    }
}