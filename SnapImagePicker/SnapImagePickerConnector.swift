import UIKit
import SnapFonts_iOS

protocol SnapImagePickerConnectorProtocol: class {
    var cameraRollAvailable: Bool { get set }
    func segueToAlbumSelector(navigationController: UINavigationController?)
    func segueToImagePicker(albumType: AlbumType, inNavigationController: UINavigationController?)
}

public class SnapImagePickerConnector {
    public enum Names: String {
        case SnapImagePickerStoryboard = "SnapImagePicker"
        case AlbumSelectorViewController = "Album Selector View Controller"
    }
    
    weak var presenter: SnapImagePickerPresenter?
    private weak var imagePickerEntityGateway: SnapImagePickerEntityGateway?
    private weak var albumSelectorEntityGateway: AlbumSelectorEntityGateway?
    private var photoLoader: PhotoLoader?
    private var _cameraRollAvailable = false
    
    init(presenter: SnapImagePickerPresenter, cameraRollAvailable: Bool) {
        self.presenter = presenter
        _cameraRollAvailable = cameraRollAvailable
        
        let interactor = SnapImagePickerInteractor(presenter: presenter)
        presenter.interactor = interactor
        
        let photoLoader = getPhotoLoader()
        let entityGateway = SnapImagePickerEntityGateway(interactor: interactor, imageLoader: photoLoader)
        interactor.entityGateway = entityGateway
        self.imagePickerEntityGateway = entityGateway
    }
    
    private func getPhotoLoader() -> PhotoLoader? {
        if !_cameraRollAvailable {
            return nil
        } else {
            if photoLoader == nil {
                photoLoader = PhotoLoader()
            }
            return photoLoader
        }
    }
}

extension SnapImagePickerConnector: SnapImagePickerConnectorProtocol {
    var cameraRollAvailable: Bool {
        get {
            return _cameraRollAvailable
        }
        set {
            _cameraRollAvailable = newValue
            let photoLoader = getPhotoLoader()
            imagePickerEntityGateway?.imageLoader = photoLoader
            albumSelectorEntityGateway?.albumLoader = photoLoader
        }
    }
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
            
            let photoLoader = getPhotoLoader()
            let entityGateway = AlbumSelectorEntityGateway(interactor: interactor, albumLoader: photoLoader)
            interactor.entityGateway = entityGateway
            self.albumSelectorEntityGateway = entityGateway
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
