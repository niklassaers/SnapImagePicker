import UIKit

protocol AlbumSelectorEventHandler: class {
    func viewWillAppear()
    func albumClicked(albumtype: AlbumType, inNavigationController: UINavigationController?)
}
