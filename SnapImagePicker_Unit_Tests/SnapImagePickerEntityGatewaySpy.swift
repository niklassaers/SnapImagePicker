@testable import SnapImagePicker
import UIKit

class SnapImagePickerEntityGatewaySpy: SnapImagePickerEntityGatewayProtocol {
    var loadInitialAlbumCount = 0
    var loadInitialAlbumType: AlbumType?
    
    var loadAlbumImageWithTypeCount = 0
    var loadAlbumImageType: AlbumType?
    var loadAlbumImageSize: CGSize?
    var loadAlbumImageAtIndex: Int?
    
    var loadImageWithLocalIdentifierCount = 0
    var loadImageWithLocalIdentifier: String?
    
    var clearPendingRequestsCount = 0
    
    private let delegate: SnapImagePickerEntityGatewaySpyDelegate?
    private let numberOfImagesInAlbums: Int?
    
    init(delegate: SnapImagePickerEntityGatewaySpyDelegate, numberOfImagesInAlbums: Int) {
        self.delegate = delegate
        self.numberOfImagesInAlbums = numberOfImagesInAlbums
    }
    
    func loadInitialAlbum(type: AlbumType) {
        loadInitialAlbumCount += 1
        loadInitialAlbumType = type
        
        delegate?.testExpectation?()
    }
    
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex: Int) -> Bool {
        loadAlbumImageWithTypeCount += 1
        loadAlbumImageType = type
        loadAlbumImageSize = targetSize
        loadAlbumImageAtIndex = atIndex
        
        delegate?.testExpectation?()
        return true
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String) -> Bool {
        loadImageWithLocalIdentifierCount += 1
        loadImageWithLocalIdentifier = localIdentifier
        
        delegate?.testExpectation?()
        return true
    }
    
    func clearPendingRequests() {
        clearPendingRequestsCount += 1
        
        delegate?.testExpectation?()
    }
}