import UIKit
import SnapImagePicker
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var delegate = SnapImagePickerNavigationControllerDelegate()
    private var vc: UIViewController?
    
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController,
            let vc = SnapImagePicker(delegate: self).initializeViewControllerWithNavigationController(navigationController) {
        addChildViewController(vc)
        containerView?.addSubview(vc.view)
            self.vc = vc
        }
    }

    @IBAction func openImagePicker(sender: UIButton) {
        imageView.hidden = true
        button.hidden = true
        containerViewLeadingConstraint?.constant -= view.frame.width
        navigationController?.navigationBar.pushNavigationItem(vc!.navigationItem, animated: true)
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
        //snapImagePicker?.disableCustomTransitionForNavigationController(self.navigationController!)
        imageView.hidden = false
        button.hidden = false
        containerViewLeadingConstraint?.constant = 0
        navigationController?.navigationBar.popNavigationItemAnimated(true)
        
    }
    
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker) {
        print("Need to request access to photos")
    }
}
