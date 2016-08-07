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
    @IBOutlet weak var accessLabel: UILabel?
    @IBOutlet weak var cameraRollAccessSwitch: UISwitch!
    
    @IBAction func loadButtonClicked(sender: UIButton) {
        (self.vc as? SnapImagePickerViewController)?.cameraRollAvailable = cameraRollAccessSwitch.on
        (self.vc as? SnapImagePickerViewController)?.loadAlbum()
    }

    var constraintCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = SnapImagePicker(delegate: self).initializeViewControllerWithPhotosAccess(cameraRollAccessSwitch.on) {
            addChildViewController(vc)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            containerView?.addSubview(vc.view)
            self.vc = vc
            automaticallyAdjustsScrollViewInsets = false
            
            let width = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            
            containerView?.addConstraints([width, centerX, height, bottom])
            vc.view.userInteractionEnabled = true
            // BREAKING: <NSLayoutConstraint:0x7fe321d57b40 UIScrollView:0x7fe32284a400.bottom == UIView:0x7fe321f38bb0.bottom>
            // ADDING: "<NSAutoresizingMaskLayoutConstraint:0x7fe321f46e60 h=--& v=--& UIScrollView:0x7fe32284a400.midY == + 333.5>
            
            /*
             */
        }
    }
    @IBAction func openImagePicker(sender: UIButton) {
        if let navigationItem = vc?.navigationItem {
            let backButton = navigationItem.backBarButtonItem
            backButton?.target = self
            backButton?.action = #selector(back)
            navigationController?.navigationBar.pushNavigationItem(navigationItem, animated: true)
            navigationItem.backBarButtonItem = backButton
            imageView.hidden = true
            button.hidden = true
            cameraRollAccessSwitch.hidden = true
            loadButton.hidden = true
            accessLabel?.hidden = true
            containerViewLeadingConstraint?.constant -= view.frame.width - 16
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
        
        print("Frame: \(vc!.view.frame)")
    }
}
