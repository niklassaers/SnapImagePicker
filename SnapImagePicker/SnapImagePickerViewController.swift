import UIKit
import Foundation

class SnapImagePickerViewController: UIViewController {   
    @IBOutlet weak var titleView: UIView?
    @IBOutlet weak var titleArrowView: DownwardsArrowView?
    
    @IBOutlet weak var titleButton: UIButton? {
        didSet {
            titleButton?.titleLabel?.font = SnapImagePickerConnector.Theme.font
            titleButton?.setTitle(AlbumType.AlbumNames.AllPhotos, forState: .Normal)
        }
    }
    
    @IBOutlet weak var selectButton: UIBarButtonItem?
    @IBOutlet weak var cancelButton: UIBarButtonItem?
    @IBOutlet weak var rotateButton: UIButton?
    
    @IBOutlet weak var albumCollectionView: UICollectionView? {
        didSet {
            albumCollectionView?.delegate = self
            albumCollectionView?.dataSource = self
        }
    }
    
    @IBOutlet weak var selectedImageView: UIImageView?
    @IBOutlet weak var selectedImageScrollView: UIScrollView? {
        didSet {
            selectedImageScrollView?.delegate = self
            selectedImageScrollView?.minimumZoomScale = 1.0
            selectedImageScrollView?.maximumZoomScale = currentDisplay.MaxZoomScale
        }
    }
    @IBOutlet weak var mainScrollView: UIScrollView? {
        didSet {
            mainScrollView?.delegate = self
        }
    }
    
    @IBOutlet weak var albumCollectionViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var albumCollectionWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var selectedImageWidthConstraint: NSLayoutConstraint? {
        willSet {
            print("Image view frame before: \(selectedImageView?.frame)")
            print("Scroll view content size before: \(selectedImageScrollView?.contentSize)")
            print("Scroll view content offset before: \(selectedImageScrollView?.contentOffset)")
            print("Zoom scale before: \(selectedImageScrollView?.zoomScale)")
            print("Scroll view frame before: \(selectedImageScrollView?.frame)")
        }
        didSet {
            print("Image view frame after: \(selectedImageView?.frame)")
            print("Scroll view content size after: \(selectedImageScrollView?.contentSize)")
            print("Scroll view content offset after: \(selectedImageScrollView?.contentOffset)")
            print("Zoom scale after: \(selectedImageScrollView?.zoomScale)")
            print("Scroll view frame after: \(selectedImageScrollView?.frame)")
        }
    }
    
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
    
    private var albumTitle: String? {
        didSet {
            titleButton?.setTitle(albumTitle, forState: .Normal)
        }
    }

    private var currentlySelectedIndex = 0 {
        didSet {
            scrollToIndex(currentlySelectedIndex)
        }
    }
    private var images = [UIImage]() {
        didSet {
            albumCollectionView?.reloadData()
        }
    }
    
    private var selectedImageRotation = Double(0)
    private var state: DisplayState = .Image {
        didSet {
            setMainOffsetForState(state)
        }
    }
    private var currentDisplay = Display.Portrait {
        didSet {
            selectedImageWidthConstraint = selectedImageWidthConstraint?.changeMultiplier(currentDisplay.SelectedImageWidthMultiplier)
            albumCollectionWidthConstraint = albumCollectionWidthConstraint?.changeMultiplier(currentDisplay.AlbumCollectionWidthMultiplier)
            albumCollectionView?.reloadData()
        }
    }
    
    private var userIsScrolling = false
    private var enqueuedBounce: (() -> Void)?
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let newDisplay = size.displayType()
        if newDisplay != currentDisplay {
            currentDisplay = newDisplay
        }
    }
    
    @IBAction func flipImageButtonPressed(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
                self.selectedImageRotation = (self.selectedImageRotation + M_PI/2) % (2 * M_PI)
                self.selectedImageScrollView?.transform = CGAffineTransformMakeRotation(CGFloat(self.selectedImageRotation))
                
                sender.enabled = false
            }, completion: {
                _ in sender.enabled = true
            })
    }
    
    @IBAction func selectButtonPressed(sender: UIBarButtonItem) {
        if let cropRect = selectedImageScrollView?.getImageBoundsForImageView(selectedImageView),
           let image = selectedImageView?.image {
            let options = ImageOptions(cropRect: cropRect, rotation: selectedImageRotation)
            eventHandler?.selectButtonPressed(image, withImageOptions: options)
        }
        dismiss()
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismiss()
    }
    
    override func viewWillAppear(animated: Bool) {
        eventHandler?.viewWillAppearWithCellSize(currentDisplay.CellWidthInViewWithWidth(view.bounds.width))
        calculateViewSizes()
        setupGestureRecognizers()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case SnapImagePickerConnector.Names.ShowAlbumSelector.rawValue:
                eventHandler?.albumTitleClicked(segue.destinationViewController)
            default: break
            }
        }
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
            
            albumCollectionViewHeightConstraint?.constant = mainFrame.height - imageSizeWhenHidden - currentDisplay.Spacing - 20 // WHY
        }
    }
}

extension SnapImagePickerViewController: SnapImagePickerViewControllerProtocol {
    func display(viewModel: SnapImagePickerViewModel) {
        albumTitle = viewModel.albumTitle
        
        if let mainImage = viewModel.mainImage {
            if mainImage != selectedImageView?.image {
                selectedImageView?.image = viewModel.mainImage
                selectedImageScrollView?.centerFullImageInImageView(selectedImageView)
            }
            self.state = .Image
        }
        
        images = viewModel.albumImages
        if (currentlySelectedIndex != viewModel.selectedIndex) {
            currentlySelectedIndex = viewModel.selectedIndex
        }
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (images.count / currentDisplay.NumberOfColumns) + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let previouslyUsedImages = section * currentDisplay.NumberOfColumns
        let remainingImages = images.count - previouslyUsedImages
        let columns = min(currentDisplay.NumberOfColumns, remainingImages)
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
                imageCell.spacing = currentDisplay.CellBorderWidth
            } else {
                imageCell.spacing = 0
            }
            
            imageCell.imageView?.contentMode = .ScaleAspectFill
            imageCell.imageView?.image = image
        }
        return cell
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.section * currentDisplay.NumberOfColumns + indexPath.row
    }
    
    private func scrollToIndex(index: Int) {
        if let albumCollectionView = albumCollectionView,
           let mainScrollView = mainScrollView {
            var row = index / currentDisplay.NumberOfColumns
            if (row == images.count / currentDisplay.NumberOfColumns) {
                row = max(0, row - 1)
            }
            var offset = CGFloat(row) * (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing)
    
            let remainingAlbumCollectionHeight = albumCollectionView.contentSize.height - offset + (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing)
            let albumStart = albumCollectionView.frame.minY
            
            if albumStart + remainingAlbumCollectionHeight < mainScrollView.frame.height {
                offset = albumCollectionView.contentSize.height - (mainScrollView.frame.height - albumCollectionView.frame.minY) + currentDisplay.NavBarHeight
            }
            
            if offset > 0 {
                albumCollectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = currentDisplay.CellWidthInView(collectionView)
        return CGSizeMake(size, size)
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Did select item at index path \(indexPath)")
        eventHandler?.albumIndexClicked((indexPath.section * currentDisplay.NumberOfColumns) + indexPath.row)
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
                        blackOverlayView?.alpha = (mainScrollView.contentOffset.y / height) * currentDisplay.MaxImageFadeRatio
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
                    scrollView.correctBoundsForImageView(imageView)
                }
            }
        } else if scrollView == albumCollectionView && !decelerate {
            scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == albumCollectionView && state == .Album {
            state = .Album
        } else if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
            
            if let imageView = selectedImageView {
                scrollView.correctBoundsForImageView(imageView)
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
                scrollView.correctBoundsForImageView(imageView)
            }
        }
    }
    
    private func scrolledToOffsetRatio(ratio: Double) {
        if state == .Album && ratio < currentDisplay.OffsetThreshold.end {
            state = .Image
        } else if state == .Image && ratio > currentDisplay.OffsetThreshold.start {
            state = .Album
        } else {
            setMainOffsetForState(state)
        }
    }
}

extension SnapImagePickerViewController {
    private func calculateOffsetToImageHeightRatio() -> Double {
        if let offset = mainScrollView?.contentOffset.y,
            let height = selectedImageScrollView?.frame.height {
            return Double((offset + currentDisplay.NavBarHeight) / height)
        }
        return 0.0
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
                        blackOverlayView?.alpha = (offset / height) * currentDisplay.MaxImageFadeRatio
                    }
                }
            }
        case .Ended, .Cancelled, .Failed:
            panEnded()
        default: break
        }
    }
    
    private func panEnded() {
        scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
    }
    
    private func setMainOffsetForState(state: DisplayState) {
        if let height = selectedImageScrollView?.bounds.height {
            let offset = (height * CGFloat(state.offset)) - currentDisplay.NavBarHeight
            UIView.animateWithDuration(0.3) {
                self.mainScrollView?.contentOffset = CGPoint(x: 0, y: offset)
                self.blackOverlayView?.alpha = (offset / height) * self.currentDisplay.MaxImageFadeRatio
            }
        }
    }
}

extension SnapImagePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return state == .Image
    }
}