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
        static let MaxImageFadeRatio = CGFloat(0.9)
    
        static func CellWidthInView(collectionView: UICollectionView) -> CGFloat {
            return (collectionView.bounds.width - (Spacing * CGFloat(NumberOfColumns - 1))) / CGFloat(NumberOfColumns)
        }
    }
    @IBOutlet weak var titleButton: UIButton? {
        didSet {
            titleButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
            titleButton?.titleLabel?.font = SnapImagePickerConnector.Theme.font
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
    
    @IBOutlet weak var imageGridView: ImageGridView? {
        didSet {
            imageGridView?.userInteractionEnabled = false
            imageGridView?.setNeedsDisplay()
        }
    }
    @IBOutlet weak var blackOverlayView: UIView? {
        didSet {
            imageGridView?.userInteractionEnabled = false
            blackOverlayView?.alpha = 0.0
        }
    }
    
    var eventHandler: SnapImagePickerEventHandlerProtocol?
    
    private var currentlySelectedIndex = 0
    private var images = [UIImage]() {
        didSet {
            albumCollectionView?.reloadData()
        }
    }
    
    private var albumCollectionViewPanRecognizer: UIPanGestureRecognizer? {
        didSet {
            if let recognizer = albumCollectionViewPanRecognizer {
                albumCollectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    private var selectedImageViewPanRecognizer: UIPanGestureRecognizer? {
        didSet {
            if let recognizer = selectedImageViewPanRecognizer {
                selectedImageScrollView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        eventHandler?.viewWillAppear()
        calculateViewSizes()
        setupGestureRecognizers()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case SnapImagePickerConnector.Names.ShowAlbumSelector.rawValue: eventHandler?.albumTitleClicked(segue.destinationViewController)
            default: break
            }
        }
    }
    
    // TODO: Remove
    override func shouldAutorotate() -> Bool {
        return false
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
        titleButton?.setTitle(viewModel.albumTitle, forState: .Normal)
        
        if let mainImage = viewModel.mainImage
           where mainImage != selectedImageView?.image {
            displayMainImage(mainImage)
        }
        
        images = viewModel.albumImages
        if (viewModel.displayState == .Image  && currentlySelectedIndex != viewModel.selectedIndex) {
            scrollToIndex(viewModel.selectedIndex)
        }
        currentlySelectedIndex = viewModel.selectedIndex
        setMainOffsetForState(viewModel.displayState)

        albumCollectionViewPanRecognizer?.enabled = viewModel.displayState == .Image
        selectedImageViewPanRecognizer?.enabled = viewModel.displayState == .Album
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
                imageCell.backgroundColor = SnapImagePickerConnector.Theme.color
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
    
    private func scrollToIndex(index: Int) {
        var row = index / UIConstants.NumberOfColumns
        if (row == images.count / UIConstants.NumberOfColumns) {
            row = max(0, row - 1)
        }
        let offset = CGFloat(row) * (UIConstants.CellWidthInView(albumCollectionView!) + UIConstants.Spacing)
        albumCollectionView?.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate
        decelerate: Bool) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
        }
    }
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
        }
    }
    
    private func setImageGridViewAlpha(alpha: CGFloat) {
        UIView.animateWithDuration(0.3) {
            [weak self] in self?.imageGridView?.alpha = alpha
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == albumCollectionView {
            let targetOffset = targetContentOffset.memory
            if targetOffset.y == 0 {
                albumCollectionView?.userInteractionEnabled = false
            }
        }
    }
}

extension SnapImagePickerViewController {
    var displayState: DisplayState? {
        return eventHandler?.displayState
    }
    
    private func setupGestureRecognizers() {
        let mainScrollViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        mainScrollView?.addGestureRecognizer(mainScrollViewPanGestureRecognizer)
        mainScrollViewPanGestureRecognizer.delegate = self
        albumCollectionViewPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        selectedImageViewPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed:
            let translation = recognizer.translationInView(mainScrollView)
            if let old = mainScrollView?.contentOffset.y {
                let offset = old - translation.y
                mainScrollView?.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                recognizer.setTranslation(CGPointZero, inView: mainScrollView)
                if let height = selectedImageView?.frame.height {
                    blackOverlayView?.alpha = (offset / height) * UIConstants.MaxImageFadeRatio
                }
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
            var offset = CGFloat.min...UIConstants.OffsetThreshold.end
        
            if prevState == .Album {
                offset = UIConstants.OffsetThreshold.start...CGFloat.max
            }
            var state = prevState
            if offset ~= ratio {
                state = (prevState == .Image) ? .Album : .Image
            }
            
            eventHandler?.userScrolledToState(state)
        }
    }
    
    private func setMainOffsetForState(state: DisplayState) {
        if let height = selectedImageScrollView?.bounds.height {
            let offset = UIConstants.NavBarHeight + (height * CGFloat(state.offset))
            UIView.animateWithDuration(0.3) {
                [weak self] in
                self?.mainScrollView?.contentOffset = CGPoint(x: 0, y: offset)
                self?.blackOverlayView?.alpha = (offset / height) * UIConstants.MaxImageFadeRatio
            }
        }
    }
}

extension SnapImagePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            if albumCollectionView?.userInteractionEnabled == false && panGesture.translationInView(albumCollectionView).y < 0 {
                albumCollectionView?.userInteractionEnabled = true
                return true
            }
        }
        return true
    }
}