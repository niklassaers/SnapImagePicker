import UIKit

class ImageSelectorViewController: UIViewController {
    @IBOutlet weak var selectedImageView: UIImageView?
    var selectedImage: UIImage? {
        didSet {
            if let imageView = selectedImageView {
                imageView.image = selectedImage
            }
        }
    }
    var albumName: String?
    var delegate: SnapImagePickerDelegate?
    
    override func viewDidLoad() {
        let vc = AlbumViewController()
        let presenter = AlbumPresenter()
        let interactor = AlbumInteractor()
        
        vc.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        
        if let selectedImageView = selectedImageView,
           let selectedImage = selectedImage {
            selectedImageView.image = selectedImage
        }
        
        if let albumName = albumName {
            title = albumName
            vc.title = title
        }
        print("Vc: \(vc)")
        addChildViewController(vc)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: #selector(selectTapped))
    }
    
    func selectTapped() {
        if let selectedImage = selectedImage {
            delegate?.pickedImage(selectedImage)
        }
        dismissViewControllerAnimated(true) {}
    }
}

extension ImageSelectorViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Images":
                if let vc = segue.destinationViewController as? AlbumViewController {
                    SnapImagePicker.setupAlbumViewController(vc)
                    vc.delegate = self
                    vc.title = title
                }
            default: break
           }
        }
    }
}

extension ImageSelectorViewController: AlbumViewControllerDelegate {
    func displaySelectedImage(image: UIImage) {
        selectedImage = image
    }
}