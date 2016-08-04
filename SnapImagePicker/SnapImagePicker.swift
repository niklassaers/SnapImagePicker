import UIKit
import SnapFonts_iOS

protocol SnapImagePickerConnectorProtocol: class {
    func segueToAlbumSelector(navigationController: UINavigationController?)
    func segueToImagePicker(albumType: AlbumType, inNavigationController: UINavigationController?)
    func setImage(image: UIImage, withImageOptions: ImageOptions)
    func requestPhotosAccess()
}

public class SnapImagePicker {
    public struct Theme {
        public static var color = UIColor.init(red: 0xFF, green: 0x00, blue: 0x58, alpha: 1)
        public static var maxImageSize = 2000
        public static var fontSize = CGFloat(20.0)
        public static var font = SnapFonts.gothamRoundedMediumOfSize(fontSize)
    }
    
    enum Names: String {
        case SnapImagePickerStoryboard = "SnapImagePicker"
        case AlbumSelectorViewController = "Album Selector View Controller"
    }
    
    private var presenter: SnapImagePickerPresenter?
    private let photoLoader = PhotoLoader()
    private let transitionDelegate = SnapImagePickerNavigationControllerDelegate()
    private var previousTransitionDelegate: UINavigationControllerDelegate?
    private var navigationController: UINavigationController?
    
    var delegate: SnapImagePickerDelegate?
    
    public init(delegate: SnapImagePickerDelegate) {
        self.delegate = delegate
    }
}

extension SnapImagePicker: SnapImagePickerProtocol {
    public func initializeViewControllerWithNavigationController(navigationController: UINavigationController) -> UIViewController? {
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
            
            return snapImagePickerViewController
        }
        
        return nil
    }
    
    public func photosAccessStatusChanged() {
        presenter?.photosAccessStatusChanged()
    }
}

extension SnapImagePicker: SnapImagePickerConnectorProtocol {
    func segueToAlbumSelector(navigationController: UINavigationController?) {
        let bundle = NSBundle(forClass: SnapImagePicker.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier(Names.AlbumSelectorViewController.rawValue) as? AlbumSelectorViewController {
            print("Segueing to album selector")
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
    
    func setImage(image: UIImage, withImageOptions options: ImageOptions) {
        navigationController?.delegate = previousTransitionDelegate
        delegate?.pickedImage(image, withImageOptions: options)
    }
    
    func requestPhotosAccess() {
        delegate?.requestPhotosAccessForImagePicker(self)
    }
}
