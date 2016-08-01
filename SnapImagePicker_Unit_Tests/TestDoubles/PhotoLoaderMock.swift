import UIKit
import Photos
@testable import SnapImagePicker

class PhotoLoaderMock: PhotoLoaderSpy {
    let numberOfImages: Int
    
    init(numberOfImages: Int) {
        self.numberOfImages = numberOfImages
    }
    
    override func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> ()) -> PHImageRequestID {
        super.loadImageFromAsset(asset, isPreview: isPreview, withPreviewSize: previewSize, handler: handler)
        
        handler(SnapImagePickerImage(image: UIImage(), localIdentifier: "localIdentifier", createdDate: nil))
        
        return 0
    }
    
    override func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: ([Int: SnapImagePickerImage]) -> ()) {
        super.loadImagesFromAssets(assets, withTargetSize: targetSize, handler: handler)
        
        var images = [Int: SnapImagePickerImage]()
        for (id, _) in assets {
            images[id] = SnapImagePickerImage(image: UIImage(), localIdentifier: "localIdentifier", createdDate: nil)
        }
        
        print("Calling handler with \(images.count)")
        handler(images)
    }
    
    override func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult? {
        super.fetchAssetsFromCollectionWithType(type)
        return PHFetchResultMock(numberOfImages: numberOfImages)
    }
}