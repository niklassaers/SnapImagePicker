import UIKit

class AlbumViewController: UICollectionViewController {
    var interactor: AlbumInteractorInput?
    var images = [UIImage]() {
        didSet {
            print("Images changed!")
            collectionView!.reloadData()
        }
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("Sections: \(images.count / 3)")
        return images.count / 3
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3 //each row have 15 columns
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("Getting cell at indexPath \(indexPath)")
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath) as? ImageCell {
            let index = indexPath.section * 3 + indexPath.row
            cell.imageView?.image = images[index]
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func viewDidLoad() {
        if let title = self.title,
           let interactor = interactor {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                print("Dispatched")
                interactor.fetchImages(title)
            }
        }
    }
}

protocol AlbumViewControllerInput : class {
    func displayImage(image: UIImage)
}

extension AlbumViewController: AlbumViewControllerInput {
    func displayImage(image: UIImage) {
        self.images.append(image)
    }
}