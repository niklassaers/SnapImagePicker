//import UIKit
//
//class SnapImagePickerEntityGatewayFake: SnapImagePickerEntityGatewayProtocol {
//    weak var interactor: SnapImagePickerInteractorProtocol?
//    
//    init(interactor: SnapImagePickerInteractorProtocol) {
//        self.interactor = interactor
//    }
//    
//    func loadAlbumWithType(type: AlbumType, withTargetSize targetSize: CGSize, inRange range: Range<Int> = 0...30) {
//        for i in range {
//            if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePickerConnector.self), compatibleWithTraitCollection: nil) {
//                interactor?.loadedAlbumImage(SnapImagePickerImage(image: image, localIdentifier: String(i), createdDate: nil))
//            }
//        }
//    }
//    
//    func loadImageWithLocalIdentifier(localIdentifier: String) {
//        if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePickerConnector.self), compatibleWithTraitCollection: nil) {
//            interactor?.loadedMainImage(SnapImagePickerImage(image: image, localIdentifier: localIdentifier, createdDate: nil))
//        }
//    }
//}