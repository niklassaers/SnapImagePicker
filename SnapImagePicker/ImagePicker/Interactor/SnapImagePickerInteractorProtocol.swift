import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadAlbum(type: AlbumType)
    func loadedAlbum(image: SnapImagePickerImage, albumSize: Int)
    func loadAlbumImageFromAlbum(type: AlbumType, atIndex: Int)
    func loadAlbumImagesFromAlbum(type: AlbumType, inRange: Range<Int>)
    func loadMainImageFromAlbum(type: AlbumType, atIndex: Int)
    func loadedAlbumImage(image: SnapImagePickerImage, fromAlbum album: AlbumType, atIndex index: Int)
    func loadedMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType)
}