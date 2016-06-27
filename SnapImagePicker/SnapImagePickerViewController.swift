import UIKit

class SnapImagePickerViewController: UIViewController {
    private struct UIConstants {
        static let Spacing = CGFloat(2)
        static let NumberOfColumns = 4
        static let BackgroundColor = UIColor.whiteColor()
        static let MaxZoomScale = 5.0
        static let CellBorderWidth = CGFloat(2.0)
        static let NavBarHeight = CGFloat(-64.0)
        static let OffsetThreshold = CGFloat(0.30)...CGFloat(0.70)
    
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
    @IBOutlet weak var albumCollectionViewHeightConstraint: NSLayoutConstraint?
    
    var eventHandler: SnapImagePickerEventHandlerProtocol?
    
    private var currentlySelectedIndex = 0
    private var images = [UIImage]() {
        didSet {
            albumCollectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        eventHandler?.viewWillAppear()
        selectedImageScrollView?.userInteractionEnabled = false
        calculateViewSizes()
        setupGestureRecognizers()
    }
    
    private func calculateViewSizes() {
        if let mainScrollView = mainScrollView,
            let imageFrame = selectedImageScrollView?.frame {
            let mainFrame = mainScrollView.frame
            let imageSizeWhenDisplayed = imageFrame.height * CGFloat(DisplayState.Album.offset)
            let imageSizeWhenHidden = imageFrame.height * (1 - CGFloat(DisplayState.Album.offset))
            mainScrollView.contentSize = CGSize(width: mainFrame.width, height: mainFrame.height + imageSizeWhenDisplayed)
            albumCollectionViewHeightConstraint?.constant = mainFrame.height - imageSizeWhenHidden - UIConstants.Spacing
        }
    }
}

extension SnapImagePickerViewController: SnapImagePickerViewControllerProtocol {
    func display(viewModel: SnapImagePickerViewModel) {
        if let mainImage = viewModel.mainImage {
            displayMainImage(mainImage)
        }
        images = viewModel.albumImages
        currentlySelectedIndex = viewModel.selectedIndex
        setMainOffsetForState(viewModel.displayState)
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
        eventHandler?.albumIndexClicked((indexPath.section * UIConstants.NumberOfColumns) + indexPath.row)
    }
}

extension SnapImagePickerViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return selectedImageView
    }
}

extension SnapImagePickerViewController {
    var displayState: DisplayState? {
        return eventHandler?.displayState
    }
    
    private func setupGestureRecognizers() {
        mainScrollView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
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
        if let offset = mainScrollView?.contentOffset.y,
           let height = selectedImageScrollView?.bounds.height,
           let prevState = eventHandler?.displayState {
            let ratio = (height - offset) / height
            var offset = CGFloat(0.0)...UIConstants.OffsetThreshold.end
        
            if prevState == .Album {
                offset = UIConstants.OffsetThreshold.start...CGFloat(1)
            }
            var state = prevState
            if offset ~= ratio {
                state = (prevState == .Image) ? .Album : .Image
            }
            
            setMainOffsetForState(state)
        }
    }
    
    private func setMainOffsetForState(state: DisplayState) {
        if let height = selectedImageScrollView?.bounds.height {
            let offset = UIConstants.NavBarHeight + (height * CGFloat(state.offset))
            mainScrollView?.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
    }
}