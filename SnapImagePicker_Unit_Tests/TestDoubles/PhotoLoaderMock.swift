import UIKit
import Photos
@testable import SnapImagePicker

class PhotoLoaderMock: PhotoLoaderSpy {
    let numberOfImages: Int
    
    init(numberOfImages: Int) {
        self.numberOfImages = numberOfImages
    }
    
    override func loadImageFromAsset(_ asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: @escaping (SnapImagePickerImage) -> ()) -> PHImageRequestID {
        let _ = super.loadImageFromAsset(asset, isPreview: isPreview, withPreviewSize: previewSize, handler: handler)
        
        handler(SnapImagePickerImage(image: UIImage(), localIdentifier: "localIdentifier", createdDate: nil))
        
        return 0
    }
    
    override func loadImagesFromAssets(_ assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: @escaping ([Int: SnapImagePickerImage]) -> ()) -> [Int: PHImageRequestID]{
        var images = [Int: SnapImagePickerImage]()
        for (id, _) in assets {
            images[id] = SnapImagePickerImage(image: UIImage(), localIdentifier: "localIdentifier", createdDate: nil)
        }
        
        handler(images)
        return super.loadImagesFromAssets(assets, withTargetSize: targetSize, handler: handler)
    }
    
    override func fetchAssetsFromCollectionWithType(_ type: AlbumType) -> PHFetchResult<PHAsset>? {
        let _ = super.fetchAssetsFromCollectionWithType(type)
        return PHFetchResultMock(numberOfImages: numberOfImages)
    }
}
