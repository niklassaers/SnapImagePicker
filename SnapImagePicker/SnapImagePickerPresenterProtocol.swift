import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentInitialAlbum(image: SnapImagePickerImage, albumSize: Int)
    func presentMainImage(image: SnapImagePickerImage)
    func presentAlbumImage(image: SnapImagePickerImage, atIndex: Int)
}