import UIKit
import SnapImagePicker
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    private var snapImagePicker: SnapImagePicker?
    private let navigationDelegate = SnapImagePickerNavigationControllerDelegate()
    private var initializedWithNavbar = false
    private var vc: UIViewController?

    @IBAction func openImagePickerWithNavbar(sender: UIButton) {
        initializedWithNavbar = true
        if let vc = snapImagePicker?.initializeNavigationController() {
            self.presentViewController(vc, animated: true, completion: nil)
            self.vc = vc
        }
    }
    
    @IBAction func openImagePickerWithoutNavbar(sender: UIButton) {
        initializedWithNavbar = false
        if let vc = snapImagePicker?.initializeViewController() {
            self.navigationController?.delegate = snapImagePicker?.getTransitioningDelegate()
            self.navigationController?.pushViewController(vc, animated: true)
            self.vc = vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snapImagePicker = SnapImagePicker(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SnapImagePickerDelegate {
    func pickedImage(image: UIImage, withImageOptions options: ImageOptions) {
        imageView?.contentMode = .ScaleAspectFit
        print("Got image: \(image)")
        imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, options.cropRect)!, scale: 1, orientation: options.rotation)
    }
    
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker) {
        print("Need to request access to photos")
    }
    
    func dismiss() {
        if initializedWithNavbar {
            vc?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
