import UIKit
import SnapFonts_iOS

public protocol SnapImagePickerProtocol {
    static func initialize(delegate delegate: SnapImagePickerDelegate) -> UIViewController?
    func photosAccessStatusChanged()
}

protocol SnapImagePickerConnectorProtocol: class {
    func prepareSegueToAlbumSelector(viewController: UIViewController)
    func prepareSegueToImagePicker(albumType: AlbumType)
    func setChosenImage(image: UIImage, withImageOptions: ImageOptions)
    func requestPhotosAccess()
}

public class SnapImagePicker {
    public struct Theme {
        static var color = UIColor.init(red: 0xFF, green: 0x00, blue: 0x58, alpha: 1)
        static var maxImageSize = 2000
        static var fontSize = CGFloat(17.0)
        static var font = SnapFonts.gothamRoundedMediumOfSize(fontSize)
    }
    
    enum Names: String {
        case SnapImagePickerStoryboard = "SnapImagePicker"
        case ShowAlbumSelector = "Show Album Selector"
    }
    
    var presenter: SnapImagePickerPresenter?
    let photoLoader = PhotoLoader()
    
    var delegate: SnapImagePickerDelegate?
    
    // Why is this needed?
    public init() {}
}

extension SnapImagePicker: SnapImagePickerProtocol {
    public static func initialize(delegate delegate: SnapImagePickerDelegate) -> UIViewController? {
        let bundle = NSBundle(forClass: SnapImagePicker.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let viewController = storyboard.instantiateInitialViewController() as? UINavigationController {
            viewController.delegate = NavigationControllerDelegate()
            if let snapImagePickerViewController = viewController.viewControllers[0] as? SnapImagePickerViewController {
                let connector = SnapImagePicker()
                let presenter = SnapImagePickerPresenter(view: snapImagePickerViewController)
                presenter.connector = connector
                snapImagePickerViewController.eventHandler = presenter
                
                let interactor = SnapImagePickerInteractor(presenter: presenter)
                presenter.interactor = interactor
                
                let entityGateway = SnapImagePickerEntityGateway(interactor: interactor, imageLoader: connector.photoLoader)
                interactor.entityGateway = entityGateway
                
                connector.presenter = presenter
                connector.delegate = delegate
                
                return viewController
            }
        }
        return nil;
    }
    
    public func photosAccessStatusChanged() {
        presenter?.photosAccessStatusChanged()
    }
}
extension SnapImagePicker: SnapImagePickerConnectorProtocol {
    func prepareSegueToAlbumSelector(viewController: UIViewController) {
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
    
    func prepareSegueToImagePicker(albumType: AlbumType) {
        if let presenterAlbumType = presenter?.albumType
           where presenterAlbumType != albumType {
            presenter?.albumType = albumType
        }
    }
    
    func setChosenImage(image: UIImage, withImageOptions options: ImageOptions) {
        delegate?.pickedImage(image, withImageOptions: options)
    }
    
    func requestPhotosAccess() {
        delegate?.requestPhotosAccessForImagePicker(self)
    }
}
