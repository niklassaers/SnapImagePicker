import UIKit

class AlbumViewController: UICollectionViewController {
    private struct UIConstants {
        static let Spacing = 2
        static let NumberOfColumns = 4
        static let BackgroundColor = UIColor.whiteColor()
    }

    var interactor: AlbumInteractorInput?
    var delegate: AlbumViewControllerDelegate?
    var images = [(id: String, image: UIImage)]() {
        didSet {
            collectionView!.reloadData()
        }
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (images.count / UIConstants.NumberOfColumns) + 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UIConstants.NumberOfColumns
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath) as? ImageCell {
            let index = indexPathToArrayIndex(indexPath)
            if index < images.count {
                cell.imageView?.image = images[index].image
                cell.imageView?.bounds = cell.bounds
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func viewDidLoad() {
        if let collectionView = collectionView {
            collectionView.backgroundColor = UIConstants.BackgroundColor
            collectionView.delegate = self
        }
        
        if let title = self.title,
           let interactor = interactor,
           let width = collectionView?.bounds.width {
            let contentSize = (width - CGFloat(6)) / CGFloat(UIConstants.NumberOfColumns) //TODO: Fetch dynamically
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                interactor.fetchAlbum(Album_Request(title: title, size: CGSize(width: contentSize, height: contentSize)))
            }
        } else {
            print("Did not dispatch because title: \(title), interactor: \(interactor), width: \(collectionView?.contentSize.width)!")
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = calculateWidthForCollectionView(collectionView)
        return CGSize(width: size, height: size)
    }
    
    private func calculateWidthForCollectionView(collectionView: UICollectionView) -> CGFloat {
        let totalSpacing = UIConstants.Spacing * (UIConstants.NumberOfColumns - 1)
        
        return (collectionView.frame.width - CGFloat(totalSpacing)) / CGFloat(UIConstants.NumberOfColumns)
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.section * UIConstants.NumberOfColumns + indexPath.row
    }
}

protocol AlbumViewControllerInput : class {
    func displayAlbumImage(response: Image_Response)
    func displayMainImage(response: Image_Response)
}

extension AlbumViewController: AlbumViewControllerInput {
    func displayAlbumImage(response: Image_Response) {
        self.images.append((id: response.id, image: response.image))
        if images.count == 1 {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                self.interactor?.fetchImage(Image_Request(id: self.images[0].id, size: CGSize(width: 2000, height: 2000)))
            }
        }
    }
    
    func displayMainImage(response: Image_Response) {
        delegate?.displaySelectedImage(response.image)
    }
}

extension AlbumViewController {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPathToArrayIndex(indexPath)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.interactor?.fetchImage(Image_Request(id: self.images[index].id, size: CGSize(width: 2000, height: 2000)))
        }
    }
}