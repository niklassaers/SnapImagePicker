import UIKit
import SnapImagePicker
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func openImagePickerTapped(sender: UIButton) {
        if let imagePicker = SnapImagePicker.initialize(delegate: self) {
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SnapImagePickerDelegate {
    func pickedImage(image: UIImage, withImageOptions options: ImageOptions) {
        imageView?.contentMode = .ScaleAspectFit
        var orientation = UIImageOrientation.Up
        switch options.rotation {
        case 0: break
        case M_PI/2: orientation = UIImageOrientation.Right
        case M_PI: orientation = UIImageOrientation.Down
        case M_PI*1.5: orientation = UIImageOrientation.Left
        default: print("Orientation: \(options.rotation)")
        }
        imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, options.cropRect)!, scale: 1, orientation: orientation)
    }
    
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker) {
        print("Need to request access to photos")
    }
}
