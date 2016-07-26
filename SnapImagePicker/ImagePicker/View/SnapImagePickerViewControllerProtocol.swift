protocol SnapImagePickerViewControllerProtocol: class {
    var albumTitle: String { get set }
    func displayMainImage(mainImage: SnapImagePickerImage)
    func reloadCellAtIndexes(index: [Int])
    func reloadAlbum()
}