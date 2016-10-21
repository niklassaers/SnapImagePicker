protocol AlbumSelectorViewControllerProtocol: class {
    func display(_ collections: [(title: String, albums: [Album])])
}
