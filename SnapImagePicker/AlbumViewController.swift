import UIKit

class AlbumViewController: UICollectionViewController {
    private let Columns = 4
    var interactor: AlbumInteractorInput?
    var delegate: AlbumViewControllerDelegate?
    var images = [UIImage]() {
        didSet {
            collectionView!.reloadData()
        }
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return images.count / Columns
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Columns
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath) as? ImageCell {
            let index = indexPathToArrayIndex(indexPath)
            cell.imageView?.image = images[index]
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func viewDidLoad() {
        if let title = self.title,
           let interactor = interactor {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                interactor.fetchImages(title)
            }
        }
        collectionView!.backgroundColor = UIColor.whiteColor()
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.section * Columns + indexPath.row
    }
}

protocol AlbumViewControllerInput : class {
    func displayImage(image: UIImage)
}

extension AlbumViewController: AlbumViewControllerInput {
    func displayImage(image: UIImage) {
        print("Displaying image")
        self.images.append(image)
    }
}

extension AlbumViewController {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPathToArrayIndex(indexPath)
        delegate?.displaySelectedImage(images[index])
    }
}