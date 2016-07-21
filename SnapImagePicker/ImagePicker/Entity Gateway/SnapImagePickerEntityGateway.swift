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
    
    func fetchAlbumImagesFromAlbum(type: AlbumType, inRange range: Range<Int>)  {
        for i in range {
            fetchAlbumImageFromAlbum(type, atIndex: i)
        }
    }
    
    func fetchMainImageFromAlbum(type: AlbumType, atIndex index: Int) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type)
            where fetchResult.count > index {
            if let asset = fetchResult.objectAtIndex(index) as? PHAsset {
                imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSize(width: 2000, height: 2000)) {
                    [weak self] (image: SnapImagePickerImage) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.interactor?.loadedMainImage(image, fromAlbum: type)
                    }
                }
            }
        }
    }
}