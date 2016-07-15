import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentInitialAlbum(image: SnapImagePickerImage, albumSize: Int)
    func presentMainImage(image: SnapImagePickerImage) -> Bool
    func presentAlbumImage(image: SnapImagePickerImage, atIndex: Int) -> Bool
    func deletedRequestAtIndex(index: Int, forAlbumType: AlbumType)
}