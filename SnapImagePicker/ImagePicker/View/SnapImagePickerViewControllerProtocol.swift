protocol SnapImagePickerViewControllerProtocol: class {
    var albumTitle: String { get set }
    func displayMainImage(_ mainImage: SnapImagePickerImage)
    func reloadCellAtIndexes(_ index: [Int])
    func reloadAlbum()
}
