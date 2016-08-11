import Photos

protocol SnapImagePickerEntityGatewayProtocol: class {
    func fetchAlbum(type: AlbumType)
    func fetchAlbumImagesFromAlbum(type: AlbumType, inRange: Range<Int>, withTargetSize: CGSize)
    func fetchMainImageFromAlbum(type: AlbumType, atIndex: Int)
    func deleteImageRequestsInRange(range: Range<Int>)
}