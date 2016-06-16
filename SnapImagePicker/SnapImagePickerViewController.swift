import UIKit

class SnapImagePickerViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar?
    @IBOutlet weak var mainScrollView: UIScrollView?
    @IBOutlet weak var selectedImageScrollView: UIScrollView? {
        didSet {
            setupSelectedImageScrollView()
        }
    }
    @IBOutlet weak var selectedImageView: UIImageView?{
        didSet {
            setupSelectedImageScrollView()
        }
    }
    @IBOutlet weak var albumCollectionView: UICollectionView?

    var collectionTitle = "Album" {
        didSet {
            setupAlbumCollectionView(collectionTitle)
        }
    }
    var selectedImage: UIImage? {
        didSet {
            setupSelectedImageScrollView()
        }
    }
    var images = [(id: String, image: UIImage)]() {
        didSet {
            if let albumCollectionView = albumCollectionView {
                albumCollectionView.reloadData()
            }
        }
    }
    
    var interactor: AlbumInteractorInput?
    
    private struct UIConstants {
        static let Spacing = CGFloat(2)
        static let NumberOfColumns = 4
        static let BackgroundColor = UIColor.whiteColor()
        static let MaxZoomScale = 5.0
        static let OffsetThreshold = 0.5
        
        static func CellWidthInView(collectionView: UICollectionView) -> CGFloat {
            return (collectionView.bounds.width - (Spacing * CGFloat(NumberOfColumns - 1))) / CGFloat(NumberOfColumns)
        }
    }
    
    private enum ContentOffset: Double {
        case DisplayImage = 0.0
        case DisplayAlbum = 0.85
    }
    
    override func viewDidLoad() {
        if let mainScrollView = mainScrollView {
            mainScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            mainScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height * 2)
        }
        setupSelectedImageScrollView()
        setupAlbumCollectionView(collectionTitle)
        setupGestureRecognizers()
    }
}

extension SnapImagePickerViewController {
    private func setupAlbumCollectionView(title: String) {
        if let albumCollectionView = albumCollectionView {
            SnapImagePicker.setupAlbumViewController(self)
            albumCollectionView.dataSource = self
            albumCollectionView.delegate = self
            albumCollectionView.backgroundColor = UIConstants.BackgroundColor
            if let interactor = interactor {
                let imageCellWidth = UIConstants.CellWidthInView(albumCollectionView)
                interactor.fetchAlbum(Album_Request(title: title, size: CGSize(width: imageCellWidth, height: imageCellWidth)))
            }
        }
    }
    
    private func setupSelectedImageScrollView() {
        if let scrollView = selectedImageScrollView,
           let imageView = selectedImageView,
           let image = selectedImage {
            let (frame, offset) = calculateFrameAndOffsetForScrollView(scrollView, withImage: image)
            imageView.frame = frame
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            
            scrollView.setZoomScale(1, animated: true)
            scrollView.contentOffset = offset
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = CGFloat(UIConstants.MaxZoomScale)
            scrollView.delegate = self
        }
    }
    
    private func calculateFrameAndOffsetForScrollView(scrollView: UIScrollView, withImage image: UIImage) -> (frame: CGRect, offset: CGPoint) {
        var width = scrollView.frame.width
        var height = scrollView.frame.height
        var offset = CGPointZero
        if image.size.height > image.size.width {
            height = height * (image.size.height/image.size.width)
            offset.y = (height - width) / 2.0
        } else if image.size.height < image.size.width {
            width = width * (image.size.width/image.size.height)
            offset.x = (width - height) / 2.0
        }
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        return (frame: frame, offset: offset)
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (images.count / UIConstants.NumberOfColumns) + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UIConstants.NumberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = UIConstants.CellWidthInView(collectionView)
        return CGSize(width: size, height: size)
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.section * UIConstants.NumberOfColumns + indexPath.row
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPathToArrayIndex(indexPath)
        if let selectedImageScrollView = selectedImageScrollView {
            let width = selectedImageScrollView.bounds.width
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                self.interactor?.fetchImage(Image_Request(id: self.images[index].id, size: CGSize(width: width, height: width)))
            }
        }
    }
}

protocol AlbumViewControllerInput : class {
    func displayAlbumImage(response: Image_Response)
    func displayMainImage(response: Image_Response)
}

extension SnapImagePickerViewController: AlbumViewControllerInput {
    func displayAlbumImage(response: Image_Response) {
        self.images.append((id: response.id, image: response.image))
        if let selectedImageScrollView = selectedImageScrollView
            where images.count == 1 {
            let width = selectedImageScrollView.bounds.width
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                self.interactor?.fetchImage(Image_Request(id: self.images[0].id, size: CGSize(width: width, height: width)))
                self.setMainOffsetTo(.DisplayImage)
            }
        }
    }
    
    func displayMainImage(response: Image_Response) {
        selectedImage = response.image
    }
}

extension SnapImagePickerViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return selectedImageView
    }
}

extension SnapImagePickerViewController {
    private func setupGestureRecognizers() {
        mainScrollView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
        albumCollectionView?.gestureRecognizerShouldBegin(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed:
            let translation = recognizer.translationInView(mainScrollView)
            if let old = mainScrollView?.contentOffset.y {
                mainScrollView?.contentOffset = CGPoint(x: 0, y: old - translation.y)
                recognizer.setTranslation(CGPointZero, inView: mainScrollView)
            }
        case .Ended:
            if let offset = mainScrollView?.contentOffset.y,
               let height = selectedImageScrollView?.bounds.height {
                let ratio = (height - offset) / height
                if ratio < CGFloat(UIConstants.OffsetThreshold) {
                    setMainOffsetTo(.DisplayAlbum)
                } else {
                    setMainOffsetTo(.DisplayImage)
                }
            }
        default: break
        }
    }
    
    func panAlbum(recognizer: UIGestureRecognizer) {
        print("PAnned")
    }
    
    private func setMainOffsetTo(offset: ContentOffset) {
        if let selectedImageScrollView = selectedImageScrollView,
           let mainScrollView = mainScrollView {
            let height = selectedImageScrollView.bounds.height
            mainScrollView.setContentOffset(CGPoint(x: 0, y: height * CGFloat(offset.rawValue)), animated: true)
        }
    }
}

class AlbumCollectionView: UICollectionView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }
}