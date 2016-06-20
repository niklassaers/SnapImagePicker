import UIKit
import SnapImagePicker

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func openImagePickerTapped(sender: UIButton) {
        
        if let imagePicker = SnapImagePicker.imagePicker(delegate: self) {
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
    func pickedImage(image: UIImage, withBounds bounds: CGRect) {
        imageView?.contentMode = .ScaleAspectFit
        print("ImageView frame: \(imageView?.frame)")
        imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, bounds)!)
        print("ImageView frame: \(imageView?.frame)")
    }
}
