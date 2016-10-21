import UIKit
import XCTest
@testable import SnapImagePicker

class SnapImagePickerEntityGatewaySpy {
    var fetchAlbumCount = 0
    var fetchAlbumType: AlbumType?
    
    var fetchAlbumImagesFromAlbumCount = 0
    var fetchAlbumImagesFromAlbumType: AlbumType?
    var fetchAlbumImagesFromAlbumRange: CountableRange<Int>?
    var fetchAlbumImagesFromAlbumSize: CGSize?
    
    var fetchMainImageFromAlbumCount = 0
    var fetchMainImageFromAlbumType: AlbumType?
    var fetchMainImageFromAlbumIndex: Int?
    
    var expectation: XCTestExpectation?
}

extension SnapImagePickerEntityGatewaySpy: SnapImagePickerEntityGatewayProtocol {
    func fetchImageWithLocalIdentifier(_ localIdentifier: String, fromAlbum type: AlbumType) {}
    
    func fetchAlbum(_ type: AlbumType) {
        fetchAlbumCount += 1
        fetchAlbumType = type
        
        expectation?.fulfill()
    }
    
    func fetchAlbumImagesFromAlbum(_ type: AlbumType, inRange: CountableRange<Int>, withTargetSize: CGSize) {
        fetchAlbumImagesFromAlbumCount += 1
        fetchAlbumImagesFromAlbumType = type
        fetchAlbumImagesFromAlbumRange = inRange
        fetchAlbumImagesFromAlbumSize = withTargetSize
        
        expectation?.fulfill()
    }
    
    func fetchMainImageFromAlbum(_ type: AlbumType, atIndex: Int) {
        fetchMainImageFromAlbumCount += 1
        fetchMainImageFromAlbumType = type
        fetchMainImageFromAlbumIndex = atIndex
        
        expectation?.fulfill()
    }
    
    func deleteImageRequestsInRange(_ range: CountableRange<Int>) {}
}
