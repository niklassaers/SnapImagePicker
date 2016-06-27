import UIKit

class SnapImagePickerViewController: UIViewController {
    private struct UIConstants {
        static let Spacing = CGFloat(2)
        static let NumberOfColumns = 4
        static let BackgroundColor = UIColor.whiteColor()
        static let MaxZoomScale = 5.0
        static let CellBorderWidth = CGFloat(2.0)
        static let TopBarHeight = CGFloat(44.0)
    
        static func CellWidthInView(collectionView: UICollectionView) -> CGFloat {
            return (collectionView.bounds.width - (Spacing * CGFloat(NumberOfColumns - 1))) / CGFloat(NumberOfColumns)
        }
    }
    
    @IBOutlet weak var albumCollectionView: UICollectionView? {
        didSet {
            albumCollectionView?.delegate = self
            albumCollectionView?.dataSource = self
        }
    }
    @IBOutlet weak var selectedImageView: UIImageView?
    @IBOutlet weak var selectedImageScrollView: UIScrollView?
    @IBOutlet weak var mainScrollView: UIScrollView?
    
    var eventHandler: SnapImagePickerEventHandlerProtocol?
    
    private var currentlySelectedIndex = 0
    private var images = [UIImage]() {
        didSet {
            albumCollectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        eventHandler?.viewWillAppear()
        setupGestureRecognizers()
    }
}

extension SnapImagePickerViewController: SnapImagePickerViewControllerProtocol {
    func display(viewModel: SnapImagePickerViewModel) {
        if let mainImage = viewModel.mainImage {
            displayMainImage(mainImage)
        }
        images = viewModel.albumImages
        currentlySelectedIndex = viewModel.selectedIndex
    }
    
    private func displayMainImage(mainImage: UIImage) {
        if let selectedImageScrollView = selectedImageScrollView,
           let selectedImageView = selectedImageView {
            selectedImageScrollView.setZoomScale(1.0, animated: false)
            selectedImageView.contentMode = .ScaleAspectFit
            selectedImageView.image = mainImage
            selectedImageView.frame = CGRect(x: 0, y: 0, width: selectedImageScrollView.frame.width, height: selectedImageScrollView.frame.height)
            selectedImageScrollView.contentSize = CGSize(width: selectedImageView.bounds.width, height: selectedImageView.bounds.height)
        
            let zoomScale = findZoomScale(mainImage)
        
            selectedImageScrollView.setZoomScale(zoomScale, animated: false)
            selectedImageScrollView.minimumZoomScale = 1.0
            selectedImageScrollView.maximumZoomScale = CGFloat(5.0)
            selectedImageScrollView.delegate = self
        }
    }
    
    private func findZoomScale(image: UIImage) -> CGFloat {
        return max(image.size.width, image.size.height)/min(image.size.width, image.size.height)
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (images.count / UIConstants.NumberOfColumns) + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let previouslyUsedImages = section * UIConstants.NumberOfColumns
        let remainingImages = images.count - previouslyUsedImages
        let columns = min(UIConstants.NumberOfColumns, remainingImages)
        return columns
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPathToArrayIndex(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath)
        if let imageCell = cell as? ImageCell
            where index < images.count  {
            let image = images[index].square()
            
            if index == currentlySelectedIndex {
                imageCell.backgroundColor = SnapImagePicker.Theme.color
                imageCell.spacing = UIConstants.CellBorderWidth
            } else {
                imageCell.spacing = 0
            }
            
            imageCell.imageView?.contentMode = .ScaleAspectFill
            imageCell.imageView?.image = image
        }
        return cell
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.section * UIConstants.NumberOfColumns + indexPath.row
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = UIConstants.CellWidthInView(collectionView)
        return CGSizeMake(size, size)
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        eventHandler?.albumIndexClicked(indexPath.row)
    }
}

extension SnapImagePickerViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return selectedImageView
    }
}

extension SnapImagePickerViewController: DisplayStateDelegate {
    var displayState: DisplayState? {
        return eventHandler?.displayState
    }
    
    private func setupGestureRecognizers() {
        mainScrollView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
        
        let albumScrollGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        albumScrollGesture.delegate = SnapImagePickerGestureRecognizerDelegate(delegate: self, shouldRecognizeInState: .Image)
        albumCollectionView?.addGestureRecognizer(albumScrollGesture)
        
        let imageScrollGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        imageScrollGesture.delegate = SnapImagePickerGestureRecognizerDelegate(delegate: self, shouldRecognizeInState: .Album)
        selectedImageScrollView?.addGestureRecognizer(imageScrollGesture)
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed:
            let translation = recognizer.translationInView(mainScrollView)
            if let old = mainScrollView?.contentOffset.y
                where old - translation.y > 0 {
                mainScrollView?.contentOffset = CGPoint(x: 0, y: old - translation.y)
                recognizer.setTranslation(CGPointZero, inView: mainScrollView)
            }
        case .Ended, .Cancelled, .Failed:
            panEnded()
        default: break
        }
    }
    
    private func panEnded() {
        //            if let offset = mainScrollView?.contentOffset.y,
        //                let height = selectedImageScrollView?.bounds.height {
        //                let ratio = (height - offset) / height
        //                let prevState = state
        //                var offset = CGFloat(0.0)...OffsetThreshold.end
        //
        //                if prevState == .Album {
        //                    offset = OffsetThreshold.start...CGFloat(1)
        //                }
        //
        //                if offset ~= ratio {
        //                    state = (prevState == .Image) ? .Album : .Image
        //                } else {
        //                    state = prevState
        //                }
        //            }
    }
}