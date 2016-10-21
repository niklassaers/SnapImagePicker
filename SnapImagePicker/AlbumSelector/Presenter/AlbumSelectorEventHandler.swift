import UIKit

protocol AlbumSelectorEventHandler: class {
    func viewWillAppear()
    func albumClicked(_ albumtype: AlbumType, inNavigationController: UINavigationController?)
}
