import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadAlbumWithType(type: AlbumType, withTargetSize targetSize: CGSize)
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize)
    func loadedAlbumImage(image: UIImage, localIdentifier: String)
    func loadedMainImage(image: UIImage, withLocalIdentifier identifier: String)
}