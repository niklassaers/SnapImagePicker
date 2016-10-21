@testable import SnapImagePicker

class SnapImagePickerViewControllerSpy {
    var _albumTitle: String = ""
    var albumTitleGetCount = 0
    var albumTitleSetCount = 0
    
    var displayMainImageCount = 0
    var displayMainImageImage: SnapImagePickerImage?
    
    var reloadCellAtIndexesCount = 0
    var reloadCellAtIndexesIndexes: [Int]?
    
    var reloadAlbumCount = 0
}

extension SnapImagePickerViewControllerSpy: SnapImagePickerViewControllerProtocol {
    var albumTitle: String {
        get {
            albumTitleGetCount += 1
            return _albumTitle
        }
        set {
            albumTitleSetCount += 1
            _albumTitle = newValue
        }
    }
    
    func displayMainImage(_ mainImage: SnapImagePickerImage) {
        displayMainImageCount += 1
        displayMainImageImage = mainImage
    }
    
    func reloadCellAtIndexes(_ index: [Int]) {
        reloadCellAtIndexesCount += 1
        reloadCellAtIndexesIndexes = index
    }
    
    func reloadAlbum() {
        reloadAlbumCount += 1
    }
}
