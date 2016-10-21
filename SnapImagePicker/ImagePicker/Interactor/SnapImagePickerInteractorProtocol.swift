import UIKit

protocol SnapImagePickerInteractorProtocol: class {
    func loadAlbum(_ type: AlbumType)
    func loadedAlbum(_ type: AlbumType, withMainImage: SnapImagePickerImage, albumSize: Int)
    func loadAlbumImagesFromAlbum(_ type: AlbumType, inRange: CountableRange<Int>, withTargetSize: CGSize)
    func loadMainImageFromAlbum(_ type: AlbumType, atIndex: Int)
    func loadedAlbumImagesResult(_ results: [Int:SnapImagePickerImage], fromAlbum: AlbumType)
    func loadMainImageWithLocalIdentifier(_ localIdentifier: String, fromAlbum album: AlbumType)
    func loadedMainImage(_ image: SnapImagePickerImage, fromAlbum: AlbumType)
    func deleteImageRequestsInRange(_ range: CountableRange<Int>)
}
