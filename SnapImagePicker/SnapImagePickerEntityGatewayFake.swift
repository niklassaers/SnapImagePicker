import UIKit

class SnapImagePickerEntityGatewayFake: SnapImagePickerEntityGatewayProtocol {
    weak var interactor: SnapImagePickerInteractorProtocol?
    
    init(interactor: SnapImagePickerInteractorProtocol) {
        self.interactor = interactor
    }
    
    func loadAlbumWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        for i in 0..<30 {
            if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePickerConnector.self), compatibleWithTraitCollection: nil) {
                interactor?.loadedAlbumImage(image, localIdentifier: String(i))
            }
        }
    }
    
    func loadImageWithLocalIdentifier(localIdentifier: String, withTargetSize targetSize: CGSize) {
        print("Loading")
        if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePickerConnector.self), compatibleWithTraitCollection: nil) {
            print("Loaded image")
            interactor?.loadedMainImage(image)
        }
    }
}