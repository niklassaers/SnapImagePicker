import UIKit

struct SnapImagePickerViewModel {
    let albumTitle: String
    let mainImage: UIImage?
    let albumImages: [UIImage]
    let displayState: DisplayState
    let selectedIndex: Int
}
