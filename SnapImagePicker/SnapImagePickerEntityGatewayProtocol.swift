import Foundation
import Photos

protocol SnapImagePickerEntityGatewayProtocol: class {
    func loadInitialAlbum(type: AlbumType)
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex: Int)
    func loadImageWithLocalIdentifier(localIdentifier: String)
    func clearPendingRequests()
}