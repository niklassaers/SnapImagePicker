import Foundation

class PhotoLoaderFake: AlbumLoader {
    var image: UIImage?
    
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        if image == nil {
            let frameworkBundle = NSBundle(forClass: SnapImagePicker.self)
            let imagePath = frameworkBundle.pathForResource("dummy", ofType: "jpeg")
            if imagePath != nil {
                image = UIImage(contentsOfFile: imagePath!)
            }
        }
        
        if let image = image {
            for i in 0..<50 {
                handler(image, String(i))
            }
        }
    }
        
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        if image == nil {
            let frameworkBundle = NSBundle(forClass: SnapImagePicker.self)
            let imagePath = frameworkBundle.pathForResource("dummy", ofType: "jpeg")
            if imagePath != nil {
                image = UIImage(contentsOfFile: imagePath!)
            }
        }
        
        if let image = image {
            handler(image, String(1))
        }
    }
}