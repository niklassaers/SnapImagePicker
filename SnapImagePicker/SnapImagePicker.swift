import Foundation

public class SnapImagePicker {
    var color = 
    private enum Names: String {
        case SnapImagePickerStoryboard = "SnapImagePicker"
        case AlbumSelectorViewController = "AlbumSelectorViewController"
    }
    
    public static func imagePicker(delegate delegate: SnapImagePickerDelegate) -> UIViewController? {
        let bundle = NSBundle(forClass: SnapImagePicker.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController,
           let imagePicker = navigationController.viewControllers[0] as? AlbumSelectorViewController {
            imagePicker.delegate = delegate
            navigationController.title = "Albums"
            
            let presenter = AlbumSelectorPresenter()
            presenter.viewController = imagePicker
            let interactor = AlbumSelectorInteractor()
            interactor.presenter = presenter
            interactor.loader = PhotoLoader()
            imagePicker.interactor = interactor
            
            return navigationController
        }
        
        return nil;
    }
    
    static func setupAlbumViewController(vc: AlbumViewController) {
        let interactor = AlbumInteractor()
        let presenter = AlbumPresenter()
        vc.interactor = interactor
        interactor.loader = PhotoLoader()
        interactor.presenter = presenter
        presenter.viewController = vc
    }
}
