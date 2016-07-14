@testable import SnapImagePicker
import UIKit

class SnapImagePickerConnectorSpy: SnapImagePickerConnectorProtocol {
    var prepareSegueToAlbumSelectorCount = 0
    var prepareSegueToImagePickerCount = 0
    
    var setChosenImageCount = 0
    var setChosenImage: UIImage?
    var setChosenImageOptions: ImageOptions?
    
    var requestPhotosAccessCount = 0
    
    private let delegate: SnapImagePickerConnectorSpyDelegate?
    
    init(delegate: SnapImagePickerConnectorSpyDelegate) {
        self.delegate = delegate
    }
    
    func prepareSegueToAlbumSelector(viewController: UIViewController) {
        prepareSegueToAlbumSelectorCount += 1
    }
    
    func prepareSegueToImagePicker(albumType: AlbumType) {
        prepareSegueToImagePickerCount += 1
    }
    
    func setChosenImage(image: UIImage, withImageOptions: ImageOptions) {
        setChosenImageCount += 1
        setChosenImage = image
        setChosenImageOptions = withImageOptions
    }
    
    func requestPhotosAccess() {
        requestPhotosAccessCount += 1
    }
}