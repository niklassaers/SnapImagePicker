import Photos

class PHFetchResultStub: PHFetchResult {
    private let numberOfImages: Int
    override var count: Int {
        get {
            return numberOfImages
        }
    }
    
    init(numberOfImages: Int) {
        self.numberOfImages = numberOfImages
    }
}