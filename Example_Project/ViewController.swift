import UIKit
import SnapImagePicker

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    private var snapImagePicker = SnapImagePickerConnector()

    @IBAction func openImagePickerTapped(sender: UIButton) {
        if let imagePicker = snapImagePicker.imagePicker(delegate: self) {
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
    func pickedImage(image: UIImage, withImageOptions options: SnapImagePicker.ImageOptions) {
        imageView?.contentMode = .ScaleAspectFit
        var orientation = UIImageOrientation.Up
        switch options.rotation {
        case 0: break
        case 90: orientation = UIImageOrientation.Right
        case
        }
        imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, options.cropRect)!, scale: 1, orientation: UIImageOrientation.options.rotation)
    }
    
    func requestPhotosAccess() {
        print("Need to request access to photos")
    }
}
