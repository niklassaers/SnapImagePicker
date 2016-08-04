import UIKit
import SnapImagePicker
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func openImagePicker(sender: UIButton) {
        let snapImagePicker = SnapImagePicker(delegate: self)
        if let navigationController = self.navigationController,
           let vc = snapImagePicker.initializeViewController() {
            navigationController.pushViewController(vc, animated: true)
            snapImagePicker.enableCustomTransitionForNavigationController(navigationController)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationController?.popViewControllerAnimated(true)
    }
    
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker) {
        print("Need to request access to photos")
    }
}
