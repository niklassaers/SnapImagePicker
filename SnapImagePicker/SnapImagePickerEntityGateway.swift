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
extension SnapImagePickerEntityGateway {
    private func loadImageFromAsset(asset: PHAsset, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
            (image: UIImage?, data: [NSObject : AnyObject]?) in
            if let image = image {
                handler(image, asset.localIdentifier)
            }
        }
    }
}

extension SnapImagePickerEntityGateway: SnapImagePickerEntityGatewayProtocol {
    func loadAlbumWithType(type: AlbumType, withTargetSize targetSize: CGSize) {
        if let fetchResult = imageLoader?.fetchPhotosFromCollectionWithType(type) {
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
            let options = PHImageRequestOptions()
            options.synchronous = true
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(width: 2000, height: 2000), contentMode: .Default, options: options) {
                [weak self] (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    self?.interactor?.loadedMainImage(image)
                }
            }
        }
    }
}