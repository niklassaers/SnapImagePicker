import UIKit
import XCTest
@testable import SnapImagePicker

class SnapImagePickerInteractorSpy {
    var loadAlbumCount = 0
    var loadAlbumType: AlbumType?
    
    var loadedAlbumCount = 0
    var loadedAlbumType: AlbumType?
    var loadedAlbumMainImage: SnapImagePickerImage?
    var loadedAlbumSize: Int?
    
    var loadAlbumImagesFromAlbumCount = 0
    var loadAlbumImagesFromAlbumType: AlbumType?
    var loadAlbumImagesFromAlbumRange: CountableRange<Int>?
    var loadAlbumImagesFromAlbumTargetSize: CGSize?
    
    var loadMainImageFromAlbumCount = 0
    var loadMainImageFromAlbumType: AlbumType?
    var loadMainImageFromAlbumIndex: Int?
    
    var loadedAlbumImagesResultCount = 0
    var loadedAlbumImagesResultResults: [Int: SnapImagePickerImage]?
    var loadedAlbumImagesResultType: AlbumType?
    
    var loadedMainImageCount = 0
    var loadedMainImageImage: SnapImagePickerImage?
    var loadedMainImageType: AlbumType?
    
    var expectation: XCTestExpectation?
}

extension SnapImagePickerInteractorSpy: SnapImagePickerInteractorProtocol {
    func loadMainImageWithLocalIdentifier(_ localIdentifier: String, fromAlbum album: AlbumType) {}
    
    func loadAlbum(_ type: AlbumType) {
        loadAlbumCount += 1
        loadAlbumType = type
    }
    
    func loadedAlbum(_ type: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int) {
        loadedAlbumCount += 1
        loadedAlbumType = type
        loadedAlbumMainImage = mainImage
        loadedAlbumSize = albumSize
        
        expectation?.fulfill()
    }
    
    func loadAlbumImagesFromAlbum(_ type: AlbumType, inRange range: CountableRange<Int>, withTargetSize targetSize: CGSize) {
        loadAlbumImagesFromAlbumCount += 1
        loadAlbumImagesFromAlbumType = type
        loadAlbumImagesFromAlbumRange = range
        loadAlbumImagesFromAlbumTargetSize = targetSize
    }
    
    func loadMainImageFromAlbum(_ type: AlbumType, atIndex index: Int) {
        loadMainImageFromAlbumCount += 1
        loadMainImageFromAlbumType = type
        loadMainImageFromAlbumIndex = index
    }
    
    func loadedAlbumImagesResult(_ results: [Int:SnapImagePickerImage], fromAlbum album: AlbumType) {
        loadedAlbumImagesResultCount += 1
        loadedAlbumImagesResultResults = results
        loadedAlbumImagesResultType = album
        
        expectation?.fulfill()
    }
    
    func loadedMainImage(_ image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        loadedMainImageCount += 1
        loadedMainImageImage = image
        loadedMainImageType = album
        
        expectation?.fulfill()
    }
    
    func deleteImageRequestsInRange(_ range: CountableRange<Int>) {}
}
