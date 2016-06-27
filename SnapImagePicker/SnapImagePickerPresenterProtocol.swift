import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentMainImage(image: UIImage)
    func presentAlbumImage(image: UIImage, id: String)
}