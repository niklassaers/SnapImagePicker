import UIKit
import Photos

class ImageLoaderMock: ImageLoader {
    let numberOfImagesInAlbum: Int
    var clearPendingRequestsWasCalled = false
    
    init(numberOfImagesInAlbum: Int) {
        self.numberOfImagesInAlbum = numberOfImagesInAlbum
    }
    
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> Void) -> PHImageRequestID {
        if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePicker.self), compatibleWithTraitCollection: nil) {
            handler(SnapImagePickerImage(image: image, localIdentifier: "testImage", createdDate: nil))
        }
        return PHImageRequestID()
    }
    
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult? {
        return PHFetchResultMock(numberOfImages: numberOfImagesInAlbum)
    }
    
    func clearPendingRequests() {
        clearPendingRequestsWasCalled = true
    }
    
    func deleteRequestForId(id: PHImageRequestID) {
        
    }
}