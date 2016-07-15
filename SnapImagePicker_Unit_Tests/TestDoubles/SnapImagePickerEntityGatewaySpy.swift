@testable import SnapImagePicker
import UIKit

class SnapImagePickerEntityGatewaySpy {
    var loadInitialAlbumCount = 0
    var loadInitialAlbumType: AlbumType?
    
    var loadAlbumImageWithTypeCount = 0
    var loadAlbumImageType: AlbumType?
    var loadAlbumImageSize: CGSize?
    var loadAlbumImageAtIndex: Int?
    
    var loadImageWithLocalIdentifierCount = 0
    var loadImageWithLocalIdentifier: String?
    
    var clearPendingRequestsCount = 0
    
    private let delegate: SnapImagePickerTestExpectationDelegate?
    private let numberOfImagesInAlbums: Int?
    
    init(delegate: SnapImagePickerTestExpectationDelegate, numberOfImagesInAlbums: Int) {
        self.delegate = delegate
        self.numberOfImagesInAlbums = numberOfImagesInAlbums
    }
    
    func loadInitialAlbum(type: AlbumType) {
        loadInitialAlbumCount += 1
        loadInitialAlbumType = type
        
        delegate?.fulfillExpectation?()
    }
    
}

extension SnapImagePickerEntityGatewaySpy : SnapImagePickerEntityGatewayProtocol {
    
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex: Int) -> Bool {
        loadAlbumImageWithTypeCount += 1
        loadAlbumImageType = type
        loadAlbumImageSize = targetSize
        loadAlbumImageAtIndex = atIndex
        
        delegate?.fulfillExpectation?()
        return true
    }
    
    func deleteRequestAtIndex(index: Int, forAlbumType type: AlbumType) {
        
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String) -> Bool {
        loadImageWithLocalIdentifierCount += 1
        loadImageWithLocalIdentifier = localIdentifier
        
        delegate?.fulfillExpectation?()
        return true
    }
    
    func clearPendingRequests() {
        clearPendingRequestsCount += 1
        
        delegate?.fulfillExpectation?()
    }
}