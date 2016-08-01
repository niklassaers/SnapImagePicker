import Photos

class PHFetchResultMock: PHFetchResult {
    let numberOfImages: Int
    
    init(numberOfImages: Int) {
        self.numberOfImages = numberOfImages
    }
    
    override var count: Int {
        get {
            return numberOfImages
        }
    }
    
    override var firstObject: AnyObject? {
        get {
            return PHAssetMock()
        }
    }
    
    override func objectAtIndex(index: Int) -> AnyObject {
        return PHAssetMock()
    }
}