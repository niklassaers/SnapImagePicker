import UIKit

protocol SnapImagePickerPresenterProtocol : class {
    func presentAlbum(_ album: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int)
    func presentMainImage(_ image: SnapImagePickerImage, fromAlbum album: AlbumType)
    func presentAlbumImages(_ results: [Int: SnapImagePickerImage], fromAlbum album: AlbumType)
}
