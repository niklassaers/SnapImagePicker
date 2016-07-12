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
    
    private var delegate: SnapImagePickerPresenterSpyDelegate?
    
    init(delegate: SnapImagePickerPresenterSpyDelegate) {
        self.delegate = delegate
    }
    
    func presentInitialAlbum(image: SnapImagePickerImage, albumSize: Int) {
        presentInitialAlbumCount += 1
        presentInitialAlbumImage = image
        presentInitialAlbumSize = albumSize
        
        delegate?.testExpectation?()
    }
    
    func presentMainImage(image: SnapImagePickerImage) -> Bool {
        presentMainImageCount += 1
        presentMainImage = image
        
        delegate?.testExpectation?()
        return true
    }
    
    func presentAlbumImage(image: SnapImagePickerImage, atIndex: Int) -> Bool {
        presentAlbumImageCount += 1
        presentAlbumImage = image
        presentAlbumImageAtIndex = atIndex
        
        delegate?.testExpectation?()
        return true
    }
}