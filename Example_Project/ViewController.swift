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
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            containerView?.addSubview(vc.view)
            self.vc = vc
            
            let leading = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            containerView?.addConstraints([leading, trailing, top, bottom])
        }
    }
    @IBAction func openImagePicker(sender: UIButton) {
        if let navigationItem = vc?.navigationItem {
            let backButton = navigationItem.backBarButtonItem
            backButton?.target = self
            backButton?.action = #selector(back)
            navigationItem.backBarButtonItem = backButton
            navigationController?.navigationBar.pushNavigationItem(navigationItem, animated: true)
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
    }
}
