import UIKit
import SnapImagePicker
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var delegate = SnapImagePickerNavigationControllerDelegate()
    private var vc: UIViewController?
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerView: UIView?
    
    @IBAction func loadButtonClicked(sender: UIButton) {
        (self.vc as? SnapImagePickerViewController)?.cameraRollAvailable = cameraRollAccessSwitch.on
        (self.vc as? SnapImagePickerViewController)?.loadAlbum()
    }
    
    @IBOutlet weak var accessLabel: UILabel?
    @IBOutlet weak var cameraRollAccessSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = SnapImagePicker(delegate: self).initializeViewControllerWithPhotosAccess(cameraRollAccessSwitch.on) {
            addChildViewController(vc)
            containerView?.addSubview(vc.view)
            self.vc = vc
        }
    }
    @IBAction func openImagePicker(sender: UIButton) {
        if let navigationItem = vc?.navigationItem {
            let backButton = navigationItem.backBarButtonItem
            backButton?.target = "self"
            backButton?.action = #selector(back)
            navigationItem.backBarButtonItem = backButton
            navigationController?.navigationBar.pushNavigationItem(navigationItem, animated: true)
            imageView.hidden = true
            button.hidden = true
            cameraRollAccessSwitch.hidden = true
            loadButton.hidden = true
            accessLabel?.hidden = true
            containerViewLeadingConstraint?.constant -= view.frame.width
        }
    }
    
    func back() {
        imageView.hidden = false
        button.hidden = false
        cameraRollAccessSwitch.hidden = false
        loadButton.hidden = false
        accessLabel?.hidden = false
        containerViewLeadingConstraint?.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SnapImagePickerDelegate {
    func pickedImage(image: UIImage, withImageOptions options: ImageOptions) {
        imageView?.contentMode = .ScaleAspectFit
        imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, options.cropRect)!, scale: 1, orientation: options.rotation)
        back()
    }
}
