import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadAlbumWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize)
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize)
    func loadedAlbumImage(image: UIImage, localIdentifier: String)
    func loadedMainImage(image: UIImage)
}