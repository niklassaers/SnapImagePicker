import Foundation
import Photos

protocol SnapImagePickerEntityGatewayProtocol: class {
    func loadAlbumWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize)
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize)
}