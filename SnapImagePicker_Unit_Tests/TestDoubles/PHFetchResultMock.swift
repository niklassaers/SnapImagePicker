import Photos

class PHFetchResultMock: PHFetchResult<PHAsset> {
    let numberOfImages: Int
    
    init(numberOfImages: Int) {
        self.numberOfImages = numberOfImages
    }
    
    override var count: Int {
        get {
            return numberOfImages
        }
    }
    
    override var firstObject: PHAsset? {
        get {
            return PHAssetMock()
        }
    }
    
    override open func object(at index: Int) -> PHAsset {
        return PHAssetMock()
    }
}
