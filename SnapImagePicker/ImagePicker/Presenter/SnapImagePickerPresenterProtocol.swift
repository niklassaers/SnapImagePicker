import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentAlbum(album: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int)
    func presentMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType)
    func presentAlbumImages(results: [Int: SnapImagePickerImage], fromAlbum album: AlbumType)
}