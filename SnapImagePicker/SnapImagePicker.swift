import UIKit
import SnapFonts_iOS

public protocol SnapImagePickerProtocol {
    func getTransitioningDelegate() -> UINavigationControllerDelegate
    func initializeViewController() -> UIViewController?
    func initializeNavigationController() -> UINavigationController?
    func photosAccessStatusChanged()
}

protocol SnapImagePickerConnectorProtocol: class {
    func prepareSegueToAlbumSelector(viewController: UIViewController)
    func prepareSegueToImagePicker(albumType: AlbumType)
    func setImage(image: UIImage, withImageOptions: ImageOptions)
    func dismiss()
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
    
    private var presenter: SnapImagePickerPresenter?
    private let photoLoader = PhotoLoader()
    private let transitionDelegate = SnapImagePickerNavigationControllerDelegate()
    private var previousTransitionDelegate: UINavigationControllerDelegate?
    
    var delegate: SnapImagePickerDelegate?
    
    // Why is this needed?
    public init(delegate: SnapImagePickerDelegate) {
        self.delegate = delegate
    }
}

extension SnapImagePicker: SnapImagePickerProtocol {
    public func getTransitioningDelegate() -> UINavigationControllerDelegate{
        return transitionDelegate
    }
    
    public func initializeViewController() -> UIViewController? {
        let viewController = initialize(false)
        
        return viewController
    }
    
    public func initializeNavigationController() -> UINavigationController? {
        if let navigationController = initialize(true) as? UINavigationController {
            navigationController.transitioningDelegate = transitionDelegate
            
            return navigationController
        }
        
        return nil
    }
    
    private func initialize(shouldReturnNavigationController: Bool) -> UIViewController? {
        let bundle = NSBundle(forClass: SnapImagePicker.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController {
            if let snapImagePickerViewController = navigationController.viewControllers[0] as? SnapImagePickerViewController {
                
                let presenter = SnapImagePickerPresenter(view: snapImagePickerViewController)
                snapImagePickerViewController.eventHandler = presenter
                presenter.connector = self
                
                let interactor = SnapImagePickerInteractor(presenter: presenter)
                presenter.interactor = interactor
                
                let entityGateway = SnapImagePickerEntityGateway(interactor: interactor, imageLoader: photoLoader)
                interactor.entityGateway = entityGateway
                
                self.presenter = presenter
                
                if shouldReturnNavigationController {
                    return navigationController
                } else {
                    return snapImagePickerViewController
                }
            }
        }
        
        return nil
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
    
    func setImage(image: UIImage, withImageOptions options: ImageOptions) {
        delegate?.pickedImage(image, withImageOptions: options)
    }
    
    func requestPhotosAccess() {
        delegate?.requestPhotosAccessForImagePicker(self)
    }
    
    func dismiss() {
        delegate?.dismiss()
    }
}
