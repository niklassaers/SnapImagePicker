import Photos

protocol SnapImagePickerEntityGatewayProtocol: class {
    func fetchAlbum(type: AlbumType)
    func fetchAlbumImageFromAlbum(type: AlbumType, atIndex: Int)
    func fetchAlbumImagesFromAlbum(type: AlbumType, inRange: Range<Int>)
    func fetchMainImageFromAlbum(type: AlbumType, atIndex: Int)
}