@testable import SnapImagePicker
import UIKit
import Photos

class ImageLoaderStub: ImageLoader {
    let numberOfImagesInAlbum: Int
    var clearPendingRequestsWasCalled = false
    
    init(numberOfImagesInAlbum: Int) {
        self.numberOfImagesInAlbum = numberOfImagesInAlbum
    }
    
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> Void) {
        if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePicker.self), compatibleWithTraitCollection: nil) {
            handler(SnapImagePickerImage(image: image, localIdentifier: "testImage", createdDate: nil))
        }
    }
    
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult? {
        return PHFetchResultStub(numberOfImages: numberOfImagesInAlbum)
    }
    
    func clearPendingRequests() {
        clearPendingRequestsWasCalled = true
    }
}