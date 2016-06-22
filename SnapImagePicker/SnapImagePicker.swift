import Foundation

public class SnapImagePicker {
    static var color = UIColor.init(red: 0xFF, green: 0x00, blue: 0x58, alpha: 1)
    private enum Names: String {
        case SnapImagePickerStoryboard = "SnapImagePicker"
        case AlbumSelectorViewController = "AlbumSelectorViewController"
    }
    
    static var photoLoader: PhotoLoader?
    
    public static func imagePicker(delegate delegate: SnapImagePickerDelegate) -> UIViewController? {
        let bundle = NSBundle(forClass: SnapImagePicker.self)
        let storyboard = UIStoryboard(name: Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let viewController = storyboard.instantiateInitialViewController() as? SnapImagePickerViewController {
            viewController.delegate = delegate
            return viewController
        }
        
        return nil;
    }
    
    static func setupAlbumViewController(vc: SnapImagePickerViewController) {
        let interactor = AlbumInteractor()
        let presenter = AlbumPresenter()
        let photoLoader = PhotoLoader()
        
        vc.interactor = interactor
        interactor.presenter = presenter
        interactor.albumLoader = photoLoader
        presenter.viewController = vc
    }
}
