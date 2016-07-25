import UIKit

class SnapImagePickerViewController: UIViewController {   
    @IBOutlet weak var titleView: UIView?
    @IBOutlet weak var titleArrowView: DownwardsArrowView?
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
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var albumCollectionViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var albumCollectionWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var selectedImageWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var mainImageLoadIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var imageGridView: ImageGridView? {
        didSet {
            imageGridView?.userInteractionEnabled = false
        }
    }
    @IBOutlet weak var blackOverlayView: UIView? {
        didSet {
            blackOverlayView?.userInteractionEnabled = false
            blackOverlayView?.alpha = 0.0
        }
    }
    
    @IBAction func flipImageButtonPressed(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.selectedImageRotation = self.selectedImageRotation.next()
            self.selectedImageScrollView?.transform = CGAffineTransformMakeRotation(CGFloat(self.selectedImageRotation.toCGAffineTransformRadians()))
            
            sender.enabled = false
            }, completion: {
                _ in sender.enabled = true
        })
    }
    
    func selectButtonPressed() {
        if let cropRect = selectedImageScrollView?.getImageBoundsForImageView(selectedImageView),
           let image = selectedImageView?.image {
           let options = ImageOptions(cropRect: cropRect, rotation: selectedImageRotation)
            eventHandler?.selectButtonPressed(image, withImageOptions: options)
        }
    }
    
    func albumTitlePressed() {
        eventHandler?.albumTitlePressed()
    }

    var eventHandler: SnapImagePickerEventHandlerProtocol?
    
    var albumTitle = L10n.AllPhotosAlbumName.string {
        didSet {
            visibleCells = nil
        }
    }

    private var currentlySelectedIndex = 0 {
        didSet {
            scrollToIndex(currentlySelectedIndex)
        }
    }
    
    private var selectedImageRotation = UIImageOrientation.Up
    
    private var state: DisplayState = .Image {
        didSet {
            setVisibleCellsInAlbumCollectionView()
            setMainOffsetForState(state)
        }
    }
    
    
    private var currentDisplay = Display.Portrait {
        didSet {
            if let contentSize = selectedImageScrollView?.contentSize,
               let zoomScale = selectedImageScrollView?.zoomScale,
               let oldMultiplier = selectedImageWidthConstraint?.multiplier {
                let ratio = currentDisplay.SelectedImageWidthMultiplier / oldMultiplier
                selectedImageWidthConstraint = selectedImageWidthConstraint?.changeMultiplier(currentDisplay.SelectedImageWidthMultiplier)
                albumCollectionWidthConstraint = albumCollectionWidthConstraint?.changeMultiplier(currentDisplay.AlbumCollectionWidthMultiplier)
                albumCollectionView?.reloadData()
                selectedImageScrollView?.contentSize = CGSize(width: contentSize.width * ratio / zoomScale, height: contentSize.height * ratio / zoomScale)
            }
        }
    }
    
    private var visibleCells: Range<Int>? {
        didSet {
            if let visibleCells = visibleCells where oldValue != visibleCells {
                eventHandler?.scrolledToCells(visibleCells, increasing: oldValue?.startIndex < visibleCells.startIndex)
            }
        }
    }

    private var userIsScrolling = false
    private var enqueuedBounce: (() -> Void)?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        currentDisplay = view.frame.size.displayType()
        eventHandler?.viewWillAppearWithCellSize(currentDisplay.CellWidthInViewWithWidth(view.bounds.width))
        calculateViewSizes()
        setupGestureRecognizers()
        automaticallyAdjustsScrollViewInsets = false
        setupTitleButton()
        setupSelectButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setVisibleCellsInAlbumCollectionView()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let newDisplay = size.displayType()
        if newDisplay != currentDisplay {
            let ratio = newDisplay.SelectedImageWidthMultiplier / currentDisplay.SelectedImageWidthMultiplier
            let newOffset = CGPoint(x: selectedImageScrollView!.contentOffset.x * ratio * ((newDisplay == .Landscape) ? 1 * 1.33 : 1 / 1.33),
                                    y: selectedImageScrollView!.contentOffset.y * ratio * ((newDisplay == .Landscape) ? 1 * 1.33 : 1 / 1.33))
            coordinator.animateAlongsideTransition({
                [weak self] _ in
                
                if let strongSelf = self,
                    let selectedImageScrollView = strongSelf.selectedImageScrollView {
                    let ratio = newDisplay.SelectedImageWidthMultiplier / strongSelf.currentDisplay.SelectedImageWidthMultiplier
                    let height = selectedImageScrollView.frame.height
                    let newHeight = height * ratio
                    strongSelf.setMainOffsetForState(strongSelf.state, withHeight: newHeight, animated: false)
                    
                    strongSelf.currentDisplay = newDisplay
                    self?.setVisibleCellsInAlbumCollectionView()
                    self?.selectedImageScrollView?.setContentOffset(newOffset, animated: true)
                    
                }
                }, completion: nil)
        }
    }
    
    func dismiss() {
        eventHandler?.dismiss()
    }
    
    private func setupSelectButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem?.title = L10n.SelectButtonLabelText.string
        if let font = SnapImagePicker.Theme.font?.fontWithSize(18) {
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font],forState: .Normal)
        }
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(selectButtonPressed)
    }
    
    private func setupTitleButton() {
        var title = albumTitle
        if albumTitle == AlbumType.AllPhotos.getAlbumName() {
            title = L10n.AllPhotosAlbumName.string
        } else if albumTitle == AlbumType.Favorites.getAlbumName() {
            title = L10n.FavoritesAlbumName.string
        }
        let button = UIButton()
        
        button.titleLabel?.font = SnapImagePicker.Theme.font
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.setTitleColor(UIColor.init(red: 0xB8/0xFF, green: 0xB8/0xFF, blue: 0xB8/0xFF, alpha: 1), forState: .Highlighted)
        if let mainImage = UIImage(named: "open_downwards_arrow", inBundle: NSBundle(forClass: SnapImagePicker.self), compatibleWithTraitCollection: nil),
           let mainCgImage = mainImage.CGImage,
           let highlightedImage = UIImage(named: "open_downwards_arrow_highlighted", inBundle: NSBundle(forClass: SnapImagePicker.self), compatibleWithTraitCollection: nil),
           let highlightedCgImage = highlightedImage.CGImage,
           let navBarHeight = navigationController?.navigationBar.frame.height {
            let scale = mainImage.size.height / navBarHeight * 2
            let scaledMainImage = UIImage(CGImage: mainCgImage, scale: scale, orientation: .Up)
            let scaledHighlightedImage = UIImage(CGImage: highlightedCgImage, scale: scale, orientation: .Up)
            
            button.setImage(scaledMainImage, forState: .Normal)
            button.setImage(scaledHighlightedImage, forState: .Highlighted)
            button.frame = CGRect(x: 0, y: 0, width: scaledMainImage.size.width, height: scaledMainImage.size.height)
        }
        button.addTarget(self, action: #selector(albumTitlePressed), forControlEvents: .TouchUpInside)
        
        self.navigationItem.titleView = button
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
    func displayMainImage(mainImage: SnapImagePickerImage) {
        selectedImageView?.image = mainImage.image
        selectedImageScrollView?.centerFullImageInImageView(selectedImageView)
        if state != .Image {
            state = .Image
        }
        mainImageLoadIndicator?.stopAnimating()
    }
    
    func reloadAlbum() {
        albumCollectionView?.reloadData()
    }
    
    func reloadCellAtIndex(index: Int) {
        albumCollectionView?.reloadItemsAtIndexPaths([arrayIndexToIndexPath(index)])
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return eventHandler?.numberOfSectionsForNumberOfColumns(currentDisplay.NumberOfColumns) ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventHandler?.numberOfItemsInSection(section, withColumns: currentDisplay.NumberOfColumns) ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPathToArrayIndex(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath)
        if let imageCell = cell as? ImageCell {
            eventHandler?.presentCell(imageCell, atIndex: index)
        }
        return cell
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return (indexPath.section * currentDisplay.NumberOfColumns) + indexPath.row
    }
    
    private func arrayIndexToIndexPath(index: Int) -> NSIndexPath {
        return NSIndexPath(forItem: Int(index % currentDisplay.NumberOfColumns), inSection: Int(index / currentDisplay.NumberOfColumns))
    }
    
    private func scrollToIndex(index: Int) {
        if let albumCollectionView = albumCollectionView,
           let mainScrollView = mainScrollView {
            let row = index / currentDisplay.NumberOfColumns
            var offset = CGFloat(row) * (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing)
    
            let remainingAlbumCollectionHeight = albumCollectionView.contentSize.height - offset + (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing)
            let albumStart = albumCollectionView.frame.minY
            
            if albumStart + remainingAlbumCollectionHeight < mainScrollView.frame.height {
                offset = albumCollectionView.contentSize.height - (mainScrollView.frame.height - albumCollectionView.frame.minY)
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
        let index = indexPathToArrayIndex(indexPath)
        eventHandler?.albumImageClicked(index)
        scrollToIndex(index)
        mainImageLoadIndicator?.startAnimating()
    }
}

extension SnapImagePickerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            mainScrollViewDidScroll(scrollView)
        } else if scrollView == albumCollectionView {
            albumCollectionViewDidScroll(scrollView)
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
}
extension SnapImagePickerViewController {
    private func mainScrollViewDidScroll(scrollView: UIScrollView) {
        if let albumCollectionView = albumCollectionView {
            let remainingAlbumCollectionHeight = albumCollectionView.contentSize.height - albumCollectionView.contentOffset.y
            let albumStart = albumCollectionView.frame.minY - scrollView.contentOffset.y
            let offset = scrollView.frame.height - (albumStart + remainingAlbumCollectionHeight)
            if offset > 0 && albumCollectionView.contentOffset.y - offset > 0 {
                albumCollectionView.contentOffset = CGPoint(x: 0, y: albumCollectionView.contentOffset.y - offset)
            }
        }
    }
    
    private func albumCollectionViewDidScroll(scrollView: UIScrollView) {
        setVisibleCellsInAlbumCollectionView()
        
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
    private func setVisibleCellsInAlbumCollectionView() {
        if let albumCollectionView = albumCollectionView {
            let topVisibleRow = Int(albumCollectionView.contentOffset.y / (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing))
            let firstVisibleCell = topVisibleRow * currentDisplay.NumberOfColumns
            let visibleAreaOfAlbumCollectionView = mainScrollView!.frame.height - selectedImageScrollView!.frame.height * CGFloat(1 - state.offset)
            let numberOfVisibleRows = Int(ceil(visibleAreaOfAlbumCollectionView / (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing)))
            let numberOfVisibleCells = numberOfVisibleRows * currentDisplay.NumberOfColumns
            let lastVisibleCell = firstVisibleCell + numberOfVisibleCells
            if (lastVisibleCell > firstVisibleCell) {
                visibleCells = firstVisibleCell...lastVisibleCell
            }
        }
    }
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
                        let alpha = (offset / height) * currentDisplay.MaxImageFadeRatio
                        blackOverlayView?.alpha = alpha
                        rotateButton?.alpha = 1 - alpha
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
    
    private func setMainOffsetForState(state: DisplayState, animated: Bool = true) {
        if let height = selectedImageScrollView?.bounds.height {
            setMainOffsetForState(state, withHeight: height, animated: animated)
        }
    }
    
    private func setMainOffsetForState(state: DisplayState, withHeight height: CGFloat, animated: Bool = true) {
        let offset = (height * CGFloat(state.offset))
        if animated {
            UIView.animateWithDuration(0.3) {
                self.mainScrollView?.contentOffset = CGPoint(x: 0, y: offset)
                self.blackOverlayView?.alpha = (offset / height) * self.currentDisplay.MaxImageFadeRatio
                self.rotateButton?.alpha = state.rotateButtonAlpha
            }
        } else {
            self.mainScrollView?.contentOffset = CGPoint(x: 0, y: offset)
            self.blackOverlayView?.alpha = (offset / height) * self.currentDisplay.MaxImageFadeRatio
            self.rotateButton?.alpha = state.rotateButtonAlpha
        }
    }
}

extension SnapImagePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return state == .Image
    }
}