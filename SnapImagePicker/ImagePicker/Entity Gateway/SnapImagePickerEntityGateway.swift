import Foundation
import Photos

class SnapImagePickerEntityGateway {
    private weak var interactor: SnapImagePickerInteractorProtocol?
    private weak var imageLoader: ImageLoader?
    private var requests = [String: [Int: PHImageRequestID]]()
    
    init(interactor: SnapImagePickerInteractorProtocol, imageLoader: ImageLoader?) {
        self.interactor = interactor
        self.imageLoader = imageLoader
    }
}

extension SnapImagePickerEntityGateway: SnapImagePickerEntityGatewayProtocol {
    func loadInitialAlbum(type: AlbumType) {
        requests[type.getAlbumName()] = [Int: PHImageRequestID]()
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            if let asset = fetchResult.firstObject as? PHAsset {
                let requestId = imageLoader?.loadImageFromAsset(asset, isPreview: false, withPreviewSize: CGSizeZero) {
                    [weak self] (image: SnapImagePickerImage) in
                    self?.interactor?.initializedAlbum(image, albumSize: fetchResult.count)
                }
                requests[type.getAlbumName()]![0] = requestId
            }
        }
    }
    
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex index: Int) -> Bool {
        if requests[type.getAlbumName()] == nil {
            requests[type.getAlbumName()] = [Int: PHImageRequestID]()
        }
        if let fetchResult = imageLoader?.fetchAssetsFromCollectionWithType(type) {
            if index < fetchResult.count {
                if let asset = fetchResult.objectAtIndex(index) as? PHAsset {
                    let requestId = imageLoader?.loadImageFromAsset(asset, isPreview: true, withPreviewSize: targetSize) {
                        [weak self] (image: SnapImagePickerImage) in
                        self?.interactor?.loadedAlbumImage(image, atIndex: index)
                    }
                    requests[type.getAlbumName()]![index] = requestId
                    return true
                }
            }
        }
        return false
    }
    
    
    func deleteRequestAtIndex(index: Int, forAlbumType type: AlbumType) {
        if let requestsForAlbum = requests[type.getAlbumName()],
           let id = requestsForAlbum[index] {
            imageLoader?.deleteRequestForId(id)
        }
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