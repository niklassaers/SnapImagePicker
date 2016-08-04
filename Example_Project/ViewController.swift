import UIKit
import SnapImagePicker
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var delegate = SnapImagePickerNavigationControllerDelegate()

    @IBAction func openImagePicker(sender: UIButton) {
        let snapImagePicker = SnapImagePicker(delegate: self)
        if let navigationController = self.navigationController,
            let vc = snapImagePicker.initializeViewController() {
            navigationController.pushViewController(vc, animated: true)
            navigationController.delegate = delegate
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
        navigationController?.delegate = nil
    }
    
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker) {
        print("Need to request access to photos")
    }
}
