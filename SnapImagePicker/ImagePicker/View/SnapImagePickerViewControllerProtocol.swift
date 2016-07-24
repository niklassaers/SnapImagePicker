protocol SnapImagePickerViewControllerProtocol: class {
    var albumTitle: String { get set }
    func displayMainImage(mainImage: SnapImagePickerImage)
    func reloadCellAtIndex(index: Int)
    func reloadAlbum()
}