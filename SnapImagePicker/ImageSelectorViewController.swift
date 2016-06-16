import UIKit

class ImageSelectorViewController: UIViewController {
    @IBOutlet weak var spacingBetweenViews: NSLayoutConstraint?
    @IBOutlet weak var selectedImageScrollView: SelectedImageScrollView? {
        didSet {
            print("Sat selected image view")
            if let selectedImageScrollView = selectedImageScrollView {
                selectedImageScrollView.delegate = selectedImageScrollView
            }
        }
    }
    var selectedImage: UIImage? {
        didSet {
            print("Sat selected image")
            if let selectedImageScrollView = selectedImageScrollView {
                selectedImageScrollView.image = selectedImage
            }
        }
    }
    var threshold = 300
    var locked: CGFloat = 100.0
    var albumName = "Album"
    var delegate: SnapImagePickerDelegate?
    var albumViewController: UICollectionViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = albumName
    }
    
    @IBAction func selectTapped(sender: UIButton) {
        if let text = sender.currentTitle,
           let selectedImage = selectedImage {
            switch text {
            case "Neste":
                delegate?.pickedImage(selectedImage)
                fallthrough
            case "X":
                dismissViewControllerAnimated(true) {}
            default:
                break
            }
        }
    }
    
    
    override func viewDidLoad() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(recognizer)
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            print("Began")
        case .Changed:
            updateVerticalPositionByAmount(recognizer.translationInView(view).y)
            print("Moved by \(recognizer.translationInView(view).y)")
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended, .Cancelled, .Failed:
            lockImageView()
        default: print("default")
        }
    }
    

    private func updateVerticalPositionByAmount(amount: CGFloat) {
        if let selectedImageScrollView = selectedImageScrollView,
           let albumViewController = albumViewController {
            let oldSelectedImageFrame = selectedImageScrollView.frame
            selectedImageScrollView.frame = CGRect(x: oldSelectedImageFrame.minX,
                                                   y: oldSelectedImageFrame.minY,
                                                   width: oldSelectedImageFrame.width,
                                                   height: oldSelectedImageFrame.height + amount)
        }
    }
    
    private func lockImageView() {
        if let selectedImageScrollView = selectedImageScrollView {
            let oldSelectedImageFrame = selectedImageScrollView.frame
            if oldSelectedImageFrame.height < CGFloat(threshold) {
                selectedImageScrollView.frame = CGRect(x: oldSelectedImageFrame.minX,
                                                       y: oldSelectedImageFrame.minY,
                                                       width: oldSelectedImageFrame.width,
                                                       height: locked)
            }
        }
    }
}

extension ImageSelectorViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Images":
                if let vc = segue.destinationViewController as? AlbumViewController {
                    SnapImagePicker.setupAlbumViewController(vc)
                    albumViewController = vc
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
        dispatch_async(dispatch_get_main_queue()) {
            self.selectedImage = image
        }
    }
}