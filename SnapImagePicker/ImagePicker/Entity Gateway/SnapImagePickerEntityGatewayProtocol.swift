import Photos

protocol SnapImagePickerEntityGatewayProtocol: class {
    func fetchAlbum(_ type: AlbumType)
    func fetchAlbumImagesFromAlbum(_ type: AlbumType, inRange: CountableRange<Int>, withTargetSize: CGSize)
    func fetchMainImageFromAlbum(_ type: AlbumType, atIndex: Int)
    func fetchImageWithLocalIdentifier(_ localIdentifier: String, fromAlbum type: AlbumType)
    func deleteImageRequestsInRange(_ range: CountableRange<Int>)
}
