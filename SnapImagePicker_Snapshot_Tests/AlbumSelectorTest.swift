@testable import SnapImagePicker
import SnapFBSnapshotBase

class AlbumSelectorTest: SnapFBSnapshotBase {
    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle(identifier: "com.snapsale.SnapImagePicker")
        let storyboard = UIStoryboard(name: "SnapImagePicker", bundle: bundle)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("Album Selector View Controller") as? AlbumSelectorViewController {
            sutBackingViewController = viewController
            sut = viewController.view
            viewController.display(createCollections())
            
            recordMode = super.recordAll || false
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func createCollections() -> [(title: String, albums: [Album])] {
        var collections = [(title: String, albums: [Album])]()
        if let image = UIImage(named: "dress.jpg", inBundle: NSBundle(forClass: SnapImagePickerAlbumTest.self), compatibleWithTraitCollection: nil) {
            for i in 0..<3 {
                var albums = [Album]()
                for j in 0..<3 {
                    albums.append(Album(size: 10*j+1, image: image, type: AlbumType.UserDefined(title: "Album \(i*3+j)")))
                }
                collections.append((title: "Collection \(i)", albums: albums))
            }
        }
        
        return collections
    }
}

