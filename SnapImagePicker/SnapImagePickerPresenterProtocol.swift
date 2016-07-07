import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentMainImage(image: UIImage, withLocalIdentifier: String)
    func presentAlbumImage(image: UIImage, id: String)
}