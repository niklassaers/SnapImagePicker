import UIKit
@testable import SnapImagePicker

class SnapImagePickerConnectorSpy {
    var segueToAlbumSelectorCount = 0
    
    var segueToImagePickerCount = 0
    var segueToImagePickerType: AlbumType?
    
    var setImageCount = 0
    var setImageImage: UIImage?
    var setImageOptions: ImageOptions?
    
    var dismissCount = 0
    
    var requestPhotosAccessCount = 0
}

extension SnapImagePickerConnectorSpy: SnapImagePickerConnectorProtocol {
    func segueToAlbumSelector() {
        segueToAlbumSelectorCount += 1
    }
    
    func segueToImagePicker(albumType: AlbumType) {
        segueToImagePickerCount += 1
        segueToImagePickerType = albumType
    }
    
    func setImage(image: UIImage, withImageOptions: ImageOptions) {
        setImageCount += 1
        setImageImage = image
        setImageOptions = withImageOptions
    }
    
    func requestPhotosAccess() {
        requestPhotosAccessCount += 1
    }
}
