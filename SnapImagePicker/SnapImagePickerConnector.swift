import UIKit
import SnapFonts_iOS



protocol SnapImagePickerConnectorProtocol: class {
    func segueToAlbumSelector(navigationController: UINavigationController?)
    func segueToImagePicker(albumType: AlbumType, inNavigationController: UINavigationController?)
}

public class SnapImagePickerConnector {
    public enum Names: String {
        case SnapImagePickerStoryboard = "SnapImagePicker"
        case AlbumSelectorViewController = "Album Selector View Controller"
    }
    
    weak var presenter: SnapImagePickerPresenter?
    private var photoLoader: PhotoLoader
    
    init(presenter: SnapImagePickerPresenter) {
        self.presenter = presenter
        photoLoader = PhotoLoader()
        
        let interactor = SnapImagePickerInteractor(presenter: presenter)
        presenter.interactor = interactor
        
        let entityGateway = SnapImagePickerEntityGateway(interactor: interactor, imageLoader: photoLoader)
        interactor.entityGateway = entityGateway
    }
}

extension SnapImagePickerConnector: SnapImagePickerConnectorProtocol {
    func segueToAlbumSelector(navigationController: UINavigationController?) {
        let bundle = NSBundle(forClass: SnapImagePickerConnector.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier(Names.AlbumSelectorViewController.rawValue) as? AlbumSelectorViewController {
            prepareSegueToAlbumSelector(viewController)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func prepareSegueToAlbumSelector(viewController: UIViewController) {
        if let albumSelectorViewController = viewController as? AlbumSelectorViewController {
            let presenter = AlbumSelectorPresenter(view: albumSelectorViewController)
            presenter.connector = self
            albumSelectorViewController.eventHandler = presenter
            
            let interactor = AlbumSelectorInteractor(presenter: presenter)
            presenter.interactor = interactor
            
            let entityGateway = AlbumSelectorEntityGateway(interactor: interactor, albumLoader: photoLoader)
            interactor.entityGateway = entityGateway
        }
    }
    
    func segueToImagePicker(albumType: AlbumType, inNavigationController navigationController: UINavigationController?) {
        if let presenterAlbumType = presenter?.albumType
           where presenterAlbumType != albumType {
            presenter?.albumType = albumType
        }
        navigationController?.popViewControllerAnimated(true)
    }
}
