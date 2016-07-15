import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadInitialAlbum(type: AlbumType)
    func loadAlbumImageWithType(type: AlbumType, withTargetSize targetSize: CGSize, atIndex: Int)
    func loadImageWithLocalIdentifier(localIdentifier: String)
    func deleteRequestForId(index: Int, forAlbumType type: AlbumType)
    func clearPendingRequests()
    func initializedAlbum(image: SnapImagePickerImage, albumSize: Int)
    func loadedAlbumImage(image: SnapImagePickerImage, atIndex: Int)
    func loadedMainImage(image: SnapImagePickerImage)
}