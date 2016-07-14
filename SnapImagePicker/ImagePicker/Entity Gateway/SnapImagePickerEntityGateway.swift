import Foundation
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
    func loadInitialAlbum(type: AlbumType) {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            if let asset = fetchResult.firstObject as? PHAsset {
                imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSizeZero) {
                    [weak self] (image: SnapImagePickerImage) in
                    self?.interactor?.initializedAlbum(image, albumSize: fetchResult.count)
                }
            }
        }
    }
    
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex index: Int) -> Bool {
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            if index < fetchResult.count {
                if let asset = fetchResult.objectAtIndex(index) as? PHAsset {
                    imageLoader?.loadImageFromAsset(asset, isPreview: true, withPreviewSize: targetSize) {
                        [weak self] (image: SnapImagePickerImage) in
                        self?.interactor?.loadedAlbumImage(image, atIndex: index)
                    }
                    return true
                }
            }
        }
        return false
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String) -> Bool {
        let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)
        if let asset = fetchResult.firstObject as? PHAsset {
            imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSizeZero) {
                [weak self] (image: SnapImagePickerImage) in
                self?.interactor?.loadedMainImage(image)
            }
            return true
        }
        return false
    }
    
    func clearPendingRequests() {
        imageLoader?.clearPendingRequests()
    }
}