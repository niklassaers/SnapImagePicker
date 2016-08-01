import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadAlbum(type: AlbumType)
    func loadedAlbum(type: AlbumType, withMainImage: SnapImagePickerImage, albumSize: Int)
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange: Range<Int>, withTargetSize: CGSize)
    func loadMainImageFromAlbum(type: AlbumType, atIndex: Int)
    func loadedAlbumImagesResult(results: [Int:SnapImagePickerImage], fromAlbum: AlbumType)
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum: AlbumType)
}