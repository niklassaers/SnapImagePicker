import UIKit
import SnapFonts_iOS

public protocol SnapImagePickerProtocol {
    func initializeViewControllerInNavigationController(navigationController: UINavigationController)
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
    private var navigationController: UINavigationController?
    
    var delegate: SnapImagePickerDelegate?
    
    // Why is this needed?
    public init(delegate: SnapImagePickerDelegate) {
        self.delegate = delegate
    }
}

extension SnapImagePicker: SnapImagePickerProtocol {
    public func initializeViewControllerInNavigationController(navigationController: UINavigationController) {
        let bundle = NSBundle(forClass: SnapImagePicker.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let snapImagePickerViewController = storyboard.instantiateInitialViewController() as? SnapImagePickerViewController {
            let presenter = SnapImagePickerPresenter(view: snapImagePickerViewController)
            snapImagePickerViewController.eventHandler = presenter
            presenter.connector = self
            
            let interactor = SnapImagePickerInteractor(presenter: presenter)
            presenter.interactor = interactor
            
            let entityGateway = SnapImagePickerEntityGateway(interactor: interactor, imageLoader: photoLoader)
            interactor.entityGateway = entityGateway
            
            self.presenter = presenter
            
            previousTransitionDelegate = navigationController.delegate
            self.navigationController = navigationController
            
            navigationController.pushViewController(snapImagePickerViewController, animated: true)
        }
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
        navigationController?.popViewControllerAnimated(true)
        navigationController?.delegate = previousTransitionDelegate
        delegate?.dismiss()
    }
}