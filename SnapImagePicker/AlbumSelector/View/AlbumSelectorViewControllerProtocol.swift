import Foundation

protocol AlbumSelectorViewControllerProtocol: class {
    func display(collections: [(title: String, albums: [Album])])
}