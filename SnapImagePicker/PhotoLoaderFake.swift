import Foundation

class PhotoLoaderFake: AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        for i in 0..<30 {
            if let image = UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePicker.self), compatibleWithTraitCollection: nil) {
                handler(image, String(i))
            }
        }
    }
    
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        if let image = UIImage(named: "dummy.jpeg") {
            handler(image, "1")
        }
    }
    
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: PhotoAlbum -> Void) {
        for i in 0..<10 {
            if let image = UIImage(named: "dummy.jpeg") {
                handler(PhotoAlbum(title: "Album \(i)", size: 30, image: image))
            }
        }
    }
}