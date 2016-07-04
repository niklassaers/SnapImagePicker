import UIKit
import SnapFonts_iOS

public protocol SnapImagePickerProtocol {
    func imagePicker(delegate delegate: SnapImagePickerDelegate) -> UIViewController?
}

protocol SnapImagePickerConnectorProtocol: class {
    func prepareSegueToAlbumSelector(viewController: UIViewController)
    func prepareSegueToImagePicker(title: String)
    func setChosenImage(image: UIImage, withCropRect cropRect: CGRect)
}

public class SnapImagePickerConnector {
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
    private let navigationDelegate = NavigationControllerDelegate()
    
    var delegate: SnapImagePickerDelegate?
    // Why is this needed?
    public init() {}
}
extension SnapImagePickerConnector: SnapImagePickerProtocol {
    public func imagePicker(delegate delegate: SnapImagePickerDelegate) -> UIViewController? {
        let bundle = NSBundle(forClass: SnapImagePickerConnector.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let viewController = storyboard.instantiateInitialViewController() as? UINavigationController {
            viewController.delegate = navigationDelegate
            if let snapImagePickerViewController = viewController.viewControllers[0] as? SnapImagePickerViewController {
                presenter = SnapImagePickerPresenter(view: snapImagePickerViewController)
                presenter?.connector = self
                snapImagePickerViewController.eventHandler = presenter
                self.delegate = delegate
                return viewController
            }
        }
        return nil;
    }
}
extension SnapImagePickerConnector: SnapImagePickerConnectorProtocol {
    func prepareSegueToAlbumSelector(viewController: UIViewController) {
        if let albumSelectorViewController = viewController as? AlbumSelectorViewController {
            let presenter = AlbumSelectorPresenter(view: albumSelectorViewController)
            presenter.connector = self
            albumSelectorViewController.eventHandler = presenter
        }
    }
    
    func prepareSegueToImagePicker(title: String) {
        presenter?.albumTitle = title
    }
    
    func setChosenImage(image: UIImage, withCropRect cropRect: CGRect) {
        delegate?.pickedImage(image, withBounds: cropRect)
    }
}
