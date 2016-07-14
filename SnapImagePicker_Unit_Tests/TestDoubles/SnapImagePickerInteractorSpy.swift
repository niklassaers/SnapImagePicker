@testable import SnapImagePicker
import UIKit

class SnapImagePickerInteractorSpy: SnapImagePickerInteractorProtocol {
    var loadInitialAlbumCount = 0
    var loadInitialAlbumType: AlbumType?
    
    var loadAlbumImageWithTypeCount = 0
    var loadAlbumImageWithType: AlbumType?
    var loadAlbumImageSize: CGSize?
    var loadAlbumImageAtIndex: Int?
    
    var loadImageWithLocalIdentifierCount = 0
    var loadImageWithLocalIdentifier: String?
    
    var clearPendingRequestsCount = 0
    
    var initializedAlbumCount = 0
    var initializedAlbumImage: SnapImagePickerImage?
    var initializedAlbumSize: Int?
    
    var loadedAlbumImageCount = 0
    var loadedAlbumImage: SnapImagePickerImage?
    var loadedAlbumImageAtIndex: Int?
    
    var loadedMainImageCount = 0
    var loadedMainImage: SnapImagePickerImage?
    
    private var delegate: SnapImagePickerTestExpectationDelegate?
    
    init(delegate: SnapImagePickerTestExpectationDelegate) {
        self.delegate = delegate
    }
    
    func loadInitialAlbum(type: AlbumType) {
        loadInitialAlbumCount += 1
        loadInitialAlbumType = type
        
        delegate?.fulfillExpectation?()
    }
    
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex: Int) {
        loadAlbumImageWithTypeCount += 1
        loadAlbumImageWithType = type
        loadAlbumImageSize = targetSize
        loadAlbumImageAtIndex = atIndex
        
        delegate?.fulfillExpectation?()
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String) {
        loadImageWithLocalIdentifierCount += 1
        loadImageWithLocalIdentifier = localIdentifier
        
        delegate?.fulfillExpectation?()
    }
    
    func clearPendingRequests() {
        clearPendingRequestsCount += 1
        
        delegate?.fulfillExpectation?()
    }
    
    func initializedAlbum(image: SnapImagePickerImage, albumSize: Int) {
        initializedAlbumCount += 1
        initializedAlbumImage = image
        initializedAlbumSize = albumSize
        
        delegate?.fulfillExpectation?()
    }
    
    func loadedAlbumImage(image: SnapImagePickerImage, atIndex: Int) {
        loadedAlbumImageCount += 1
        loadedAlbumImage = image
        loadedAlbumImageAtIndex = atIndex
        
        delegate?.fulfillExpectation?()
    }
    
    func loadedMainImage(image: SnapImagePickerImage) {
        loadedMainImageCount += 1
        loadedMainImage = image
        
        delegate?.fulfillExpectation?()
    }
}