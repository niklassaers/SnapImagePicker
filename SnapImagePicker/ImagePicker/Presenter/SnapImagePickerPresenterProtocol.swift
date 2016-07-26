import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentAlbum(image: SnapImagePickerImage, albumSize: Int)
    func presentMainImage(image: SnapImagePickerImage)
    func presentAlbumImages(results: [Int:SnapImagePickerImage])
}