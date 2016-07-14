@testable import SnapImagePicker

class SnapImagePickerPresenterSpy: SnapImagePickerPresenterProtocol {
    var presentInitialAlbumCount = 0
    var presentInitialAlbumImage: SnapImagePickerImage?
    var presentInitialAlbumSize: Int?
    
    var presentMainImageCount = 0
    var presentMainImage: SnapImagePickerImage?
    
    var presentAlbumImageCount = 0
    var presentAlbumImage: SnapImagePickerImage?
    var presentAlbumImageAtIndex: Int?
    
    private var delegate: SnapImagePickerTestExpectationDelegate?
    
    init(delegate: SnapImagePickerTestExpectationDelegate) {
        self.delegate = delegate
    }
    
    func presentInitialAlbum(image: SnapImagePickerImage, albumSize: Int) {
        presentInitialAlbumCount += 1
        presentInitialAlbumImage = image
        presentInitialAlbumSize = albumSize
        
        delegate?.fulfillExpectation?()
    }
    
    func presentMainImage(image: SnapImagePickerImage) -> Bool {
        presentMainImageCount += 1
        presentMainImage = image
        
        delegate?.fulfillExpectation?()
        return true
    }
    
    func presentAlbumImage(image: SnapImagePickerImage, atIndex: Int) -> Bool {
        presentAlbumImageCount += 1
        presentAlbumImage = image
        presentAlbumImageAtIndex = atIndex
        
        delegate?.fulfillExpectation?()
        return true
    }
}