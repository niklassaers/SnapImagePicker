import Foundation
import Photos

protocol SnapImagePickerEntityGatewayProtocol: class {
    func loadAlbumWithType(type: AlbumType, withTargetSize targetSize: CGSize)
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize)
}