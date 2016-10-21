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
    fileprivate let delegate = SnapImagePickerNavigationControllerDelegate()
    fileprivate var vc: SnapImagePickerViewController?
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var accessLabel: UILabel?
    @IBOutlet weak var cameraRollAccessSwitch: UISwitch!
    
    @IBAction func loadButtonClicked(_ sender: UIButton) {
        vc?.cameraRollAccess = cameraRollAccessSwitch.isOn
        vc?.reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = SnapImagePickerViewController.initializeWithCameraRollAccess(cameraRollAccessSwitch.isOn) {
            vc.delegate = self
            addChildViewController(vc)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            containerView?.addSubview(vc.view)
            self.vc = vc
            automaticallyAdjustsScrollViewInsets = false
            
            let width = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: vc.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            
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
            
            selectButton.setTitleTextAttributes(attributes, for: UIControlState())
            selectButton.setTitleTextAttributes(attributes, for: .highlighted)
        }
        selectButton.target = self
        selectButton.action = #selector(selectButtonPressed)
        navigationItem.rightBarButtonItem = selectButton
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {
            _ in
            if self.containerViewLeadingConstraint?.constant != 0 {
                self.containerViewLeadingConstraint?.constant = -self.containerView!.frame.width
            }
        }, completion: nil)
    }
    
    @IBAction func openImagePicker(_ sender: UIButton) {
        imageView.isHidden = true
        button.isHidden = true
        cameraRollAccessSwitch.isHidden = true
        loadButton.isHidden = true
        accessLabel?.isHidden = true
        containerViewLeadingConstraint?.constant = -containerView!.frame.width
        navigationController?.delegate = delegate
    }
    
    func backButtonPressed() {
        imageView.isHidden = false
        button.isHidden = false
        cameraRollAccessSwitch.isHidden = false
        loadButton.isHidden = false
        accessLabel?.isHidden = false
        containerViewLeadingConstraint?.constant = 0
        navigationController?.delegate = nil
    }
    
    func selectButtonPressed() {
        if let (image, options) = vc?.getCurrentImage(),
           let cgImage = image.cgImage {
            imageView?.contentMode = .scaleAspectFit
            imageView?.image = UIImage(cgImage: cgImage.cropping(to: options.cropRect)!, scale: 1, orientation: options.rotation)
        }
        backButtonPressed()
    }
}

extension ViewController: SnapImagePickerDelegate {
    func setTitleView(_ titleView: UIView) {
        navigationItem.titleView = titleView
    }
    
    func prepareForTransition() {
        print("Preparing for transition")
    }
}
