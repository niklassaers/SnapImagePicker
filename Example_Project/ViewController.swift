import UIKit
import SnapImagePicker
import Foundation
import MapKit
import SnapFonts_iOS

class Annotation: NSObject, MKAnnotation {
    @objc var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: 10, longitude: 10)
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    private let delegate = SnapImagePickerNavigationControllerDelegate()
    private var vc: SnapImagePickerViewController?
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var accessLabel: UILabel?
    @IBOutlet weak var cameraRollAccessSwitch: UISwitch!
    
    @IBAction func loadButtonClicked(sender: UIButton) {
        vc?.cameraRollAccess = cameraRollAccessSwitch.on
        vc?.reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = SnapImagePickerViewController.initializeWithCameraRollAccess(cameraRollAccessSwitch.on) {
            vc.delegate = self
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
        }
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        backButton.target = self
        backButton.action = #selector(backButtonPressed)
        navigationItem.leftBarButtonItem = backButton
        
        let selectButton = UIBarButtonItem()
        selectButton.title = "NESTE"
        if let font = SnapFonts.gothamRoundedMediumOfSize(SnapImagePickerTheme.fontSize - 5) {
            let attributes: [String: AnyObject] = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: SnapImagePickerTheme.color
            ]
            
            selectButton.setTitleTextAttributes(attributes, forState: .Normal)
            selectButton.setTitleTextAttributes(attributes, forState: .Highlighted)
        }
        selectButton.target = self
        selectButton.action = #selector(selectButtonPressed)
        navigationItem.rightBarButtonItem = selectButton
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            _ in
            if self.containerViewLeadingConstraint?.constant != 0 {
                self.containerViewLeadingConstraint?.constant = -self.containerView!.frame.width
            }
        }, completion: nil)
    }
    
    @IBAction func openImagePicker(sender: UIButton) {
        imageView.hidden = true
        button.hidden = true
        cameraRollAccessSwitch.hidden = true
        loadButton.hidden = true
        accessLabel?.hidden = true
        containerViewLeadingConstraint?.constant = -containerView!.frame.width
        navigationController?.delegate = delegate
    }
    
    func backButtonPressed() {
        imageView.hidden = false
        button.hidden = false
        cameraRollAccessSwitch.hidden = false
        loadButton.hidden = false
        accessLabel?.hidden = false
        containerViewLeadingConstraint?.constant = 0
        navigationController?.delegate = nil
    }
    
    func selectButtonPressed() {
        if let (image, options) = vc?.getCurrentImage(),
           let cgImage = image.CGImage {
            imageView?.contentMode = .ScaleAspectFit
            imageView?.image = UIImage(CGImage: CGImageCreateWithImageInRect(cgImage, options.cropRect)!, scale: 1, orientation: options.rotation)
        }
        backButtonPressed()
    }
}

extension ViewController: SnapImagePickerDelegate {
    func setTitleView(titleView: UIView) {
        navigationItem.titleView = titleView
    }
    
    func prepareForTransition() {
        print("Preparing for transition")
    }
}
