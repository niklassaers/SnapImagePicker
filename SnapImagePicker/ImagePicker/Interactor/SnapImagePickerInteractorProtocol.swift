import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadAlbum(type: AlbumType)
    func loadedAlbum(image: SnapImagePickerImage, albumSize: Int)
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange: Range<Int>)
    func loadMainImageFromAlbum(type: AlbumType, atIndex: Int)
    func loadedAlbumImagesResult(results: [Int:SnapImagePickerImage], fromAlbum album: AlbumType)
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType)
}