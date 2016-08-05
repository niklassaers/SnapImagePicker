import UIKit

public class SnapImagePickerViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView? {
        didSet {
            mainScrollView?.delegate = self
        }
    }
    
    @IBOutlet weak var selectedImageScrollView: UIScrollView? {
        didSet {
            selectedImageScrollView?.delegate = self
            selectedImageScrollView?.minimumZoomScale = 1.0
            selectedImageScrollView?.maximumZoomScale = currentDisplay.MaxZoomScale
        }
    }
    @IBOutlet weak var selectedImageView: UIImageView?
    private var selectedImage: SnapImagePickerImage? {
        didSet {
            if let selectedImage = selectedImage {
                selectedImageView?.image = selectedImage.image
            }
        }
    }
    
    @IBOutlet weak var albumCollectionView: UICollectionView? {
        didSet {
            albumCollectionView?.delegate = self
            albumCollectionView?.dataSource = self
        }
    }
    
    @IBOutlet weak var selectedImageScrollViewHeightToFrameWidthAspectRatioConstraint: NSLayoutConstraint?
    
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

    @IBOutlet weak var selectedImageViewAspectRationConstraint: NSLayoutConstraint?
    @IBOutlet weak var imageGridViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var albumCollectionViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var albumCollectionWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var selectedImageWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var selectedImageScrollViewTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var mainImageLoadIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var rotateButton: UIButton?
    
    @IBAction func flipImageButtonPressed(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.selectedImageRotation = self.selectedImageRotation.next()
            
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
        eventHandler?.albumTitlePressed(self.navigationController)
    }

    var eventHandler: SnapImagePickerEventHandlerProtocol?
    public var cameraRollAvailable: Bool {
        get {
            return eventHandler?.cameraRollAvailable ?? false
        }
        set {
            eventHandler?.cameraRollAvailable = newValue
            if !newValue {
                selectedImageView?.image = nil
                albumCollectionView?.reloadData()
            }
        }
    }
    
    public func loadAlbum() {
        let width = currentDisplay.CellWidthInViewWithWidth(view.bounds.width)
        eventHandler?.viewWillAppearWithCellSize(CGSize(width: width, height: width))
        if let visibleCells = visibleCells {
            eventHandler?.scrolledToCells(visibleCells, increasing: true)
        } else {
            setVisibleCellsInAlbumCollectionView()
        }
    }
    
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
    
    private var selectedImageRotation = UIImageOrientation.Up {
        didSet {
            self.selectedImageScrollView?.transform = CGAffineTransformMakeRotation(CGFloat(self.selectedImageRotation.toCGAffineTransformRadians()))
        }
    }
    
    private var state: DisplayState = .Image {
        didSet {
            selectedImageScrollView?.userInteractionEnabled = state == .Image
            setVisibleCellsInAlbumCollectionView()
            setMainOffsetForState(state)
        }
    }
    
    private var currentDisplay = Display.Portrait {
        didSet {
            albumCollectionWidthConstraint = albumCollectionWidthConstraint?.changeMultiplier(currentDisplay.AlbumCollectionWidthMultiplier)
            albumCollectionView?.reloadData()
            selectedImageScrollViewHeightToFrameWidthAspectRatioConstraint = selectedImageScrollViewHeightToFrameWidthAspectRatioConstraint?.changeMultiplier(currentDisplay.SelectedImageWidthMultiplier)
            imageGridViewWidthConstraint = imageGridViewWidthConstraint?.changeMultiplier(currentDisplay.SelectedImageWidthMultiplier)
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
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        currentDisplay = view.frame.size.displayType()
        let width = currentDisplay.CellWidthInViewWithWidth(view.bounds.width)
        eventHandler?.viewWillAppearWithCellSize(CGSize(width: width, height: width))
        
        calculateViewSizes()
        setupGestureRecognizers()
        automaticallyAdjustsScrollViewInsets = false
        setupTitleButton()
        setupSelectButton()
        selectedImageScrollView?.userInteractionEnabled = true
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setVisibleCellsInAlbumCollectionView()
    }

    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
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
                    self?.calculateViewSizes()
                }
                }, completion: nil)
        }
    }
}
extension SnapImagePickerViewController {
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
        if let mainScrollView = mainScrollView {
            let mainFrame = mainScrollView.frame
            let imageSizeWhenDisplayed = view.frame.width * CGFloat(currentDisplay.SelectedImageWidthMultiplier) * CGFloat(DisplayState.Album.offset)
            let imageSizeWhenHidden = view.frame.width * CGFloat(currentDisplay.SelectedImageWidthMultiplier) * (1 - CGFloat(DisplayState.Album.offset))
            mainScrollView.contentSize = CGSize(width: mainFrame.width, height: mainFrame.height + imageSizeWhenDisplayed)
            
            albumCollectionViewHeightConstraint?.constant = view.frame.height - imageSizeWhenHidden - currentDisplay.NavBarHeight
        }
    }
}

extension SnapImagePickerViewController: SnapImagePickerViewControllerProtocol {
    func displayMainImage(mainImage: SnapImagePickerImage) {
        if selectedImage == nil || mainImage.localIdentifier != selectedImage!.localIdentifier || mainImage.image.size.height > selectedImage!.image.size.height {
            selectedImageView?.contentMode = .ScaleAspectFit
            selectedImage = mainImage
            selectedImageRotation = .Up
            if (mainImage.image.size.width < mainImage.image.size.height) {
                selectedImageWidthConstraint = selectedImageWidthConstraint?.changeMultiplier(mainImage.image.size.width / mainImage.image.size.height * currentDisplay.SelectedImageWidthMultiplier)
                selectedImageViewAspectRationConstraint = selectedImageViewAspectRationConstraint?.changeMultiplier(mainImage.image.size.width/mainImage.image.size.height)
                selectedImageScrollView?.minimumZoomScale = 1
                selectedImageScrollView?.centerFullImageInImageView(selectedImageView)
            } else {
                let ratio = mainImage.image.size.width / mainImage.image.size.height
                selectedImageWidthConstraint = selectedImageWidthConstraint?.changeMultiplier(1)
                selectedImageViewAspectRationConstraint = selectedImageViewAspectRationConstraint?.changeMultiplier(ratio)
                selectedImageScrollView?.minimumZoomScale = mainImage.image.size.height / mainImage.image.size.width
                selectedImageScrollView?.centerFullImageInImageView(selectedImageView)
            }
        }
        
        if state != .Image {
            state = .Image
        }
        
        mainImageLoadIndicator?.stopAnimating()
    }
    
    func reloadAlbum() {
        albumCollectionView?.reloadData()
    }
    
    func reloadCellAtIndexes(indexes: [Int]) {
        var indexPaths = [NSIndexPath]()
        for index in indexes {
            indexPaths.append(arrayIndexToIndexPath(index))
        }
        
        albumCollectionView?.reloadItemsAtIndexPaths(indexPaths)
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventHandler?.numberOfItemsInSection(section) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPathToArrayIndex(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath)
        if let imageCell = cell as? ImageCell {
            eventHandler?.presentCell(imageCell, atIndex: index)
        }
        return cell
    }
    
    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.item
    }
    
    private func arrayIndexToIndexPath(index: Int) -> NSIndexPath {
        return NSIndexPath(forItem: index, inSection: 0)
    }
    
    private func scrollToIndex(index: Int) {
        if let albumCollectionView = albumCollectionView {
            let row = index / currentDisplay.NumberOfColumns
            let offset = CGFloat(row) * (currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing)
            
            // Does not scroll to index if 
            if offset + albumCollectionView.frame.height > albumCollectionView.contentSize.height {
                return
            }
            
            if offset > 0 {
                albumCollectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = currentDisplay.CellWidthInView(collectionView)
        return CGSizeMake(size, size)
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPathToArrayIndex(indexPath)
        eventHandler?.albumImageClicked(index)
        scrollToIndex(index)
        mainImageLoadIndicator?.startAnimating()
    }
}

extension SnapImagePickerViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            mainScrollViewDidScroll(scrollView)
        } else if scrollView == albumCollectionView {
            albumCollectionViewDidScroll(scrollView)
        }
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return selectedImageView
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        userIsScrolling = false
        if scrollView == albumCollectionView && velocity.y != 0.0 && targetContentOffset.memory.y == 0 {
            enqueuedBounce = {
                self.mainScrollView?.manuallyBounceBasedOnVelocity(velocity)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        userIsScrolling = true
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)

        } else if scrollView == albumCollectionView && !decelerate {
            scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == albumCollectionView && state == .Album {
            state = .Album
        } else if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
        }
    }
    
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        if scrollView == selectedImageScrollView {
            if let imageView = selectedImageView,
               let image = imageView.image {
                if image.size.height > image.size.width {
                    let ratio = min(1, imageView.frame.width / scrollView.frame.height)
                    selectedImageWidthConstraint = selectedImageWidthConstraint?.changeMultiplier(ratio)
                } else if image.size.width > image.size.height {
                    
                }
            }
        }
    }
    
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
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
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return state == .Image
    }
}