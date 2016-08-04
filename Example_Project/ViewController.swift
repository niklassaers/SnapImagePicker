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
    
    @IBOutlet weak var cameraRollAccessSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = SnapImagePicker(delegate: self).initializeViewControllerWithPhotosAccess(cameraRollAccessSwitch.on) {
            addChildViewController(vc)
            containerView?.addSubview(vc.view)
            self.vc = vc
            navigationController?.navigationBar.pushNavigationItem(vc.navigationItem, animated: true)
        }
    }
    @IBAction func openImagePicker(sender: UIButton) {
        imageView.hidden = true
        button.hidden = true
        cameraRollAccessSwitch.hidden = true
        loadButton.hidden = true
        containerViewLeadingConstraint?.constant -= view.frame.width
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SnapImagePickerDelegate {
    func pickedImage(image: UIImage, withImageOptions options: ImageOptions) {
        print("Picked image")
        imageView?.contentMode = .ScaleAspectFit
        imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, options.cropRect)!, scale: 1, orientation: options.rotation)
        imageView.hidden = false
        button.hidden = false
        cameraRollAccessSwitch.hidden = false
        loadButton.hidden = false
        containerViewLeadingConstraint?.constant = 0
    }
    
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker) {
        print("Need to request access to photos")
    }
}
