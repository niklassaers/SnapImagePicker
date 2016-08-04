public protocol SnapImagePickerViewControllerProtocol: class {
    func loadAlbum()
    func clearAlbum()
}

protocol InternalSnapImagePickerViewControllerProtocol: class {
    var albumTitle: String { get set }
    func displayMainImage(mainImage: SnapImagePickerImage)
    func reloadCellAtIndexes(index: [Int])
    func reloadAlbum()
}