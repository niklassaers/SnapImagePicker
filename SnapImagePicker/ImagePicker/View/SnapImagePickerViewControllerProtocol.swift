protocol SnapImagePickerViewControllerProtocol: class {
    func displayMainImage(mainImage: SnapImagePickerImage)
    func reloadCellAtIndex(index: Int)
    func reloadAlbum()
}