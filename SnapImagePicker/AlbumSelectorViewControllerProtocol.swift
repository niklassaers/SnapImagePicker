import Foundation

protocol AlbumSelectorViewControllerProtocol: class {
    func display(collections: [String: [Album]])
}