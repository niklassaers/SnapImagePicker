import UIKit

class SnapImagePickerViewController: UIViewController {
    private struct UIConstants {
        static let Spacing = CGFloat(2)
        static let NumberOfColumns = 4
        static let BackgroundColor = UIColor.whiteColor()
        static let MaxZoomScale = CGFloat(5)
        static let CellBorderWidth = CGFloat(2)
        static let NavBarHeight = CGFloat(64)
        static let OffsetThreshold = CGFloat(0.2)...CGFloat(0.8)
        static let MaxImageFadeRatio = CGFloat(1.2)
    
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
    @IBOutlet weak var selectButton: UIBarButtonItem?
    @IBOutlet weak var cancelButton: UIBarButtonItem?
    
    @IBOutlet weak var albumCollectionView: UICollectionView? {
        didSet {
            albumCollectionView?.delegate = self
            albumCollectionView?.dataSource = self
        }
    }
    
    @IBOutlet weak var selectedImageView: UIImageView?
    @IBOutlet weak var selectedImageScrollView: UIScrollView?
    @IBOutlet weak var mainScrollView: UIScrollView? {
        didSet {
            mainScrollView?.delegate = self
        }
    }
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

    private var userIsScrolling = false
    private var enqueuedBounce: (() -> Void)?
    private var enqueuedMove: (() -> Void)?
    
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
    
    @IBAction func selectButtonPressed(sender: UIBarButtonItem) {
        if let cropRect = selectedImageScrollView?.getImageBoundsForImageView(selectedImageView),
           let image = selectedImageView?.image {
            eventHandler?.selectButtonPressed(image, withCropRect: cropRect)
        }
        dismiss()
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismiss()
    }

    private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func calculateViewSizes() {
        if let mainScrollView = mainScrollView,
           let imageFrame = selectedImageScrollView?.frame {
            let mainFrame = mainScrollView.frame
            let imageSizeWhenDisplayed = imageFrame.height * CGFloat(DisplayState.Album.offset)
            let imageSizeWhenHidden = imageFrame.height * (1 - CGFloat(DisplayState.Album.offset))
            mainScrollView.contentSize = CGSize(width: mainFrame.width, height: mainFrame.height + imageSizeWhenDisplayed)
            
            albumCollectionViewHeightConstraint?.constant = mainFrame.height - imageSizeWhenHidden - UIConstants.Spacing - 20 // WHY
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
    }
    
    private func displayMainImage(mainImage: UIImage) {
        if let selectedImageScrollView = selectedImageScrollView,
           let selectedImageView = selectedImageView {
            selectedImageScrollView.setZoomScale(1.0, animated: false)
            selectedImageView.contentMode = .ScaleAspectFit
            selectedImageView.image = mainImage
            
            // Necessary circularity?
            selectedImageView.frame = CGRect(x: 0,
                                             y: 0,
                                             width: selectedImageScrollView.frame.width,
                                             height: selectedImageScrollView.frame.height)
            selectedImageScrollView.contentSize = CGSize(width: selectedImageView.bounds.width,
                                                         height: selectedImageView.bounds.height)
            
            let zoomScale = findZoomScale(mainImage)
            let offset = findCenteredOffsetForImage(mainImage, withZoomScale: zoomScale)
            let scaledOffset = offset * selectedImageView.bounds.width / max(mainImage.size.width, mainImage.size.height)
            
            selectedImageScrollView.delegate = self
            selectedImageScrollView.minimumZoomScale = 1.0
            selectedImageScrollView.maximumZoomScale = UIConstants.MaxZoomScale
            selectedImageScrollView.setZoomScale(zoomScale, animated: false)
            selectedImageScrollView.setContentOffset(CGPoint(x: scaledOffset, y: scaledOffset), animated: false)
        }
    }
    
    private func findZoomScale(image: UIImage) -> CGFloat {
        return max(image.size.width, image.size.height)/min(image.size.width, image.size.height)
    }
    
    private func findCenteredOffsetForImage(image: UIImage, withZoomScale zoomScale: CGFloat) -> CGFloat {
        return abs(image.size.height - image.size.width) * zoomScale / 2
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
        if let albumCollectionView = albumCollectionView,
           let mainScrollView = mainScrollView {
            var row = index / UIConstants.NumberOfColumns
            if (row == images.count / UIConstants.NumberOfColumns) {
                row = max(0, row - 1)
            }
            var offset = CGFloat(row) * (UIConstants.CellWidthInView(albumCollectionView) + UIConstants.Spacing)
    
            let remainingAlbumCollectionHeight = albumCollectionView.contentSize.height - offset + (UIConstants.CellWidthInView(albumCollectionView) + UIConstants.Spacing)
            let albumStart = albumCollectionView.frame.minY
            
            if albumStart + remainingAlbumCollectionHeight < mainScrollView.frame.height {
                offset = albumCollectionView.contentSize.height - (mainScrollView.frame.height - albumCollectionView.frame.minY) + UIConstants.NavBarHeight
            }
            
            if offset > 0 {
                albumCollectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            if let albumCollectionView = albumCollectionView,
               let mainScrollView = mainScrollView {
                let remainingAlbumCollectionHeight = albumCollectionView.contentSize.height - albumCollectionView.contentOffset.y
                let albumStart = albumCollectionView.frame.minY - mainScrollView.contentOffset.y
                let offset = mainScrollView.frame.height - (albumStart + remainingAlbumCollectionHeight)
                if offset > 0 && albumCollectionView.contentOffset.y - offset > 0 {
                    albumCollectionView.contentOffset = CGPoint(x: 0, y: albumCollectionView.contentOffset.y - offset)
                }
            }
        } else if (scrollView == albumCollectionView) {
            if let mainScrollView = mainScrollView
               where scrollView.contentOffset.y < 0 {
                if userIsScrolling {
                    mainScrollView.contentOffset = CGPoint(x: mainScrollView.contentOffset.x, y: mainScrollView.contentOffset.y + scrollView.contentOffset.y)
                    if let height = selectedImageView?.frame.height {
                        blackOverlayView?.alpha = (mainScrollView.contentOffset.y / height) * UIConstants.MaxImageFadeRatio
                    }
                } else if let enqueuedBounce = enqueuedBounce {
                    enqueuedBounce()
                    self.enqueuedBounce = nil
                }
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return selectedImageView
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        userIsScrolling = false
        if scrollView == albumCollectionView && velocity.y != 0.0 && targetContentOffset.memory.y == 0 {
            enqueuedBounce = {
                self.mainScrollView?.manuallyBounceBasedOnVelocity(velocity)
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        userIsScrolling = true
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
            
            if let imageView = selectedImageView {
                if scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= scrollView.contentSize.width && scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.height {
                    correctImageViewInScrollView(scrollView, imageView: imageView)
                }
            }
        } else if scrollView == albumCollectionView && !decelerate {
            eventHandler?.scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == albumCollectionView && eventHandler?.displayState == .Album {
            eventHandler?.userScrolledToState(.Album)
        } else if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
            
            if let imageView = selectedImageView {
                correctImageViewInScrollView(scrollView, imageView: imageView)
            }
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
            if let imageView = selectedImageView {
                correctImageViewInScrollView(scrollView, imageView: imageView)
            }
        }
    }
}

extension SnapImagePickerViewController {
    private func calculateOffsetToImageHeightRatio() -> Double {
        if let offset = mainScrollView?.contentOffset.y,
            let height = selectedImageScrollView?.frame.height {
            return Double((offset + UIConstants.NavBarHeight) / height)
        }
        return 0.0
    }
    
    private func correctImageViewInScrollView(scrollView: UIScrollView, imageView: UIImageView) {
        if let image = imageView.image,
            let currentlyVisibleRect = scrollView.getImageBoundsForImageView(imageView) {
            if imageView.bounds.width == imageView.bounds.height {
                let maxRatio = imageView.bounds.width / max(image.size.width, image.size.height)
                let scale = scrollView.zoomScale
                
                let widthRatio = imageView.bounds.width / image.size.width
                let leftMargin = currentlyVisibleRect.minX * widthRatio
                let rightMargin = scrollView.bounds.width - (currentlyVisibleRect.maxX * widthRatio)
                if (leftMargin < 0 || rightMargin < 0) && leftMargin != rightMargin {
                    let imageWidth = image.size.width * maxRatio
                    if imageWidth * scale < imageView.bounds.width {
                        scrollView.centerScrollViewHorizontally()
                    } else {
                        scrollView.clearExcessHorizontalMarginForImage(image, withMargins: (left: leftMargin, right: rightMargin))
                    }
                }
                
                let heightRatio = imageView.bounds.width / image.size.height
                let topMargin = currentlyVisibleRect.minY * heightRatio
                let bottomMargin = scrollView.bounds.height - (currentlyVisibleRect.maxY * heightRatio)
                if (topMargin < 0 || bottomMargin < 0) && topMargin != bottomMargin {
                    let imageHeight = image.size.height * maxRatio
                    if imageHeight * scale < imageView.bounds.height {
                        scrollView.centerScrollViewVertically()
                    } else {
                        scrollView.clearExcessVerticalMarginForImage(image, withMargins: (top: topMargin, bottom: bottomMargin))
                    }
                }
            }
        }
    }
    
    private func setImageGridViewAlpha(alpha: CGFloat) {
        UIView.animateWithDuration(0.3) {
            [weak self] in self?.imageGridView?.alpha = alpha
        }
    }
}

extension SnapImagePickerViewController {
    private func setupGestureRecognizers() {
        let mainScrollViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        mainScrollView?.addGestureRecognizer(mainScrollViewPanGestureRecognizer)
        let albumCollectionPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        albumCollectionPanGestureRecognizer.delegate = self
        albumCollectionView?.addGestureRecognizer(albumCollectionPanGestureRecognizer)
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed:
            let translation = recognizer.translationInView(mainScrollView)
            if let mainScrollView = mainScrollView {
                let old = mainScrollView.contentOffset.y
                let offset = old - translation.y
                
                if mainScrollView.contentSize.height - offset > mainScrollView.frame.height {
                    mainScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                    recognizer.setTranslation(CGPointZero, inView: mainScrollView)
                    if let height = selectedImageView?.frame.height {
                        blackOverlayView?.alpha = (offset / height) * UIConstants.MaxImageFadeRatio
                    }
                }
            }
        case .Ended, .Cancelled, .Failed:
            panEnded()
        default: break
        }
    }
    
    private func panEnded() {
        eventHandler?.scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
    }
    
    private func setMainOffsetForState(state: DisplayState) {
        if let height = selectedImageScrollView?.bounds.height {
            let offset = (height * CGFloat(state.offset)) - UIConstants.NavBarHeight
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
        return eventHandler?.displayState == .Image
    }
}