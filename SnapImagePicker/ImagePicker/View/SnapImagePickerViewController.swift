import UIKit

public class SnapImagePickerViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView? {
        didSet {
            mainScrollView?.bounces = false
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
    @IBOutlet weak var selectedImageScrollViewHeightToFrameWidthAspectRatioConstraint: NSLayoutConstraint?
    
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
    @IBOutlet weak var albumCollectionViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var albumCollectionWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var imageGridView: ImageGridView? {
        didSet {
            imageGridView?.userInteractionEnabled = false
        }
    }
    @IBOutlet weak var imageGridViewWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var blackOverlayView: UIView? {
        didSet {
            blackOverlayView?.userInteractionEnabled = false
            blackOverlayView?.alpha = 0.0
        }
    }

    @IBOutlet weak var mainImageLoadIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var rotateButton: UIButton?
    @IBOutlet weak var rotateButtonLeadingConstraint: NSLayoutConstraint?
    
    @IBAction func rotateButtonPressed(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.selectedImageRotation = self.selectedImageRotation.next()
            sender.enabled = false
            
            }, completion: {
                _ in sender.enabled = true
        })
    }
    
    private var _delegate: SnapImagePickerDelegate?
    var eventHandler: SnapImagePickerEventHandlerProtocol?
    
    var albumTitle = L10n.AllPhotosAlbumName.string {
        didSet {
            visibleCells = nil
            setupTitleButton()
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
            let imageInteractionEnabled = (state == .Image)
            rotateButton?.enabled = imageInteractionEnabled
            selectedImageScrollView?.userInteractionEnabled = imageInteractionEnabled
            setVisibleCellsInAlbumCollectionView()
            setMainOffsetForState(state)
        }
    }
    
    private var currentDisplay = Display.Portrait {
        didSet {
            albumCollectionWidthConstraint =
                albumCollectionWidthConstraint?.changeMultiplier(currentDisplay.AlbumCollectionWidthMultiplier)
            albumCollectionView?.reloadData()
            selectedImageScrollViewHeightToFrameWidthAspectRatioConstraint =
                selectedImageScrollViewHeightToFrameWidthAspectRatioConstraint?.changeMultiplier(currentDisplay.SelectedImageWidthMultiplier)
            imageGridViewWidthConstraint =
                imageGridViewWidthConstraint?.changeMultiplier(currentDisplay.SelectedImageWidthMultiplier)

            setRotateButtonConstraint()
        }
    }
    
    private func setRotateButtonConstraint() {
        let ratioNotCoveredByImage = (1 - currentDisplay.SelectedImageWidthMultiplier)
        let widthNotCoveredByImage = ratioNotCoveredByImage * view.frame.width
        let selectedImageStart = widthNotCoveredByImage / 2
        
        rotateButtonLeadingConstraint?.constant = selectedImageStart + 20
    }
    
    private var visibleCells: Range<Int>? {
        didSet {
            if let visibleCells = visibleCells where oldValue != visibleCells {
                let increasing = oldValue?.startIndex < visibleCells.startIndex
                eventHandler?.scrolledToCells(visibleCells, increasing: increasing)
            }
        }
    }

    private var userIsScrolling = false
    private var enqueuedBounce: (() -> Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        calculateViewSizes()
        setupGestureRecognizers()
        setupTitleButton()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currentDisplay = view.frame.size.displayType()
        let width = currentDisplay.CellWidthInViewWithWidth(view.bounds.width)
        eventHandler?.viewWillAppearWithCellSize(CGSize(width: width, height: width))
        
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
            let offsetRatio = ratio * ((newDisplay == .Landscape) ? 1 * 1.33 : 1 / 1.33)
            let newOffset = selectedImageScrollView!.contentOffset * offsetRatio
            coordinator.animateAlongsideTransition({
                [weak self] _ in
                
                if let strongSelf = self,
                    let selectedImageScrollView = strongSelf.selectedImageScrollView {
                    let height = selectedImageScrollView.frame.height
                    let newHeight = height * ratio
                    
                    strongSelf.setMainOffsetForState(strongSelf.state, withHeight: newHeight, animated: false)
                }
                
                self?.selectedImageScrollView?.setContentOffset(newOffset, animated: true)
                self?.currentDisplay = newDisplay
                self?.setVisibleCellsInAlbumCollectionView()
                self?.calculateViewSizes()
                }, completion: {
                    [weak self] _ in
                    
                    if let size = self?.selectedImage?.image.size {
                        let zoomScale = self?.selectedImageScrollView?.zoomScale ?? 1.0
                        let insets = self?.getInsetsForSize(size, withZoomScale: zoomScale) ?? UIEdgeInsetsZero
                        self?.selectedImageScrollView?.contentInset = insets
                    }
            })
        }
    }
}

extension SnapImagePickerViewController: SnapImagePickerProtocol {
    public var delegate: SnapImagePickerDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }
    
    public static func initializeWithCameraRollAccess(cameraRollAccess: Bool) -> SnapImagePickerViewController? {
        let bundle = NSBundle(forClass: SnapImagePickerViewController.self)
        let storyboard = UIStoryboard(name: SnapImagePickerConnector.Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let snapImagePickerViewController = storyboard.instantiateInitialViewController() as? SnapImagePickerViewController {
            let presenter = SnapImagePickerPresenter(view: snapImagePickerViewController, cameraRollAccess: cameraRollAccess)
            snapImagePickerViewController.eventHandler = presenter
            snapImagePickerViewController.cameraRollAccess = cameraRollAccess
            
            return snapImagePickerViewController
        }
        
        return nil
    }
    
    public var cameraRollAccess: Bool {
        get {
            return eventHandler?.cameraRollAccess ?? false
        }
        set {
            eventHandler?.cameraRollAccess = newValue
            if !newValue {
                selectedImageView?.image = nil
                selectedImage = nil
                albumCollectionView?.reloadData()
            }
        }
    }
    
    public func reload() {
        let width = self.currentDisplay.CellWidthInViewWithWidth(view.bounds.width)
        eventHandler?.viewWillAppearWithCellSize(CGSize(width: width, height: width))
        if let visibleCells = visibleCells {
            eventHandler?.scrolledToCells(visibleCells, increasing: true)
        } else {
            setVisibleCellsInAlbumCollectionView()
        }
    }
    
    public func getCurrentImage() -> (image: UIImage, options: ImageOptions)? {
        if let scrollView = selectedImageScrollView,
            let image = selectedImage?.image {
            if image.size.height > image.size.width {
                let viewRatio = image.size.width / scrollView.contentSize.width
                let diff = (image.size.height - image.size.width) / 2
                
                let cropRect = CGRect(x: scrollView.contentOffset.x * viewRatio,
                                      y: (scrollView.contentOffset.y * viewRatio) + diff,
                                      width: scrollView.bounds.width * viewRatio,
                                      height: scrollView.bounds.height * viewRatio)

                let options = ImageOptions(cropRect: cropRect, rotation: selectedImageRotation)
                return (image: image, options: options)
            } else {
                let viewRatio = image.size.height / scrollView.contentSize.height
                let diff = (image.size.width - image.size.height) / 2
                
                let cropRect = CGRect(x: (scrollView.contentOffset.x * viewRatio) + diff,
                                      y: (scrollView.contentOffset.y * viewRatio),
                                      width: scrollView.bounds.width * viewRatio,
                                      height: scrollView.bounds.height * viewRatio)
                
                let options = ImageOptions(cropRect: cropRect, rotation: selectedImageRotation)
                return (image: image, options: options)
            }
        }
        
        return nil
    }
}

extension SnapImagePickerViewController {
    func albumTitlePressed() {
        eventHandler?.albumTitlePressed(self.navigationController)
    }
    
    private func setupTitleButton() {
        var title = albumTitle
        if albumTitle == AlbumType.AllPhotos.getAlbumName() {
            title = L10n.AllPhotosAlbumName.string
        } else if albumTitle == AlbumType.Favorites.getAlbumName() {
            title = L10n.FavoritesAlbumName.string
        }
        let button = UIButton()
        setupTitleButtonTitle(button, withTitle: title)
        setupTitleButtonImage(button)

        button.addTarget(self, action: #selector(albumTitlePressed), forControlEvents: .TouchUpInside)
        
        navigationItem.titleView = button
        delegate?.setTitleView(button)
    }
    
    private func setupTitleButtonTitle(button: UIButton, withTitle title: String) {
        button.titleLabel?.font = SnapImagePickerTheme.font
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.setTitleColor(UIColor.init(red: 0xB8/0xFF, green: 0xB8/0xFF, blue: 0xB8/0xFF, alpha: 1), forState: .Highlighted)
    }
    
    private func setupTitleButtonImage(button: UIButton) {
        if let mainImage = UIImage(named: "icon_s_arrow_down_gray", inBundle: NSBundle(forClass: SnapImagePickerViewController.self), compatibleWithTraitCollection: nil),
            let mainCgImage = mainImage.CGImage,
            let navBarHeight = navigationController?.navigationBar.frame.height {
            let scale = mainImage.findRoundedScale(mainImage.size.height / (navBarHeight / 6))
            let scaledMainImage = UIImage(CGImage: mainCgImage, scale: scale, orientation: .Up)
            let scaledHighlightedImage = scaledMainImage.setAlpha(0.3)
            
            button.setImage(scaledMainImage, forState: .Normal)
            button.setImage(scaledHighlightedImage, forState: .Highlighted)
            button.frame = CGRect(x: 0, y: 0, width: scaledHighlightedImage.size.width, height: scaledHighlightedImage.size.height)
            
            button.rightAlignImage(scaledHighlightedImage)
        }
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
        let size = mainImage.image.size
        
        if selectedImage == nil
           || mainImage.localIdentifier != selectedImage!.localIdentifier
           || size.height > selectedImage!.image.size.height {
            setMainImage(mainImage)
            
            selectedImageScrollView?.contentInset = getInsetsForSize(size)
            selectedImageScrollView?.minimumZoomScale = min(size.width, size.height) / max(size.width, size.height)
            selectedImageScrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            selectedImageScrollView?.setZoomScale(1, animated: false)
        }
        
        if state != .Image {
            state = .Image
        }
        
        mainImageLoadIndicator?.stopAnimating()
    }
    
    private func setMainImage(mainImage: SnapImagePickerImage) {
        selectedImageView?.contentMode = .ScaleAspectFill
        selectedImage = mainImage
        selectedImageRotation = .Up
    }
    
    private func getInsetsForSize(size: CGSize, withZoomScale zoomScale: CGFloat = 1) -> UIEdgeInsets{
        if (size.height > size.width) {
            return getInsetsForTallRectangle(size, withZoomScale: zoomScale)
        } else {
            return getInsetsForWideRectangle(size, withZoomScale: zoomScale)
        }
    }
    
    private func getInsetsForTallRectangle(size: CGSize, withZoomScale zoomScale: CGFloat = 1) -> UIEdgeInsets {
        if let scrollView = selectedImageScrollView {
            let ratio = scrollView.frame.width / size.width
            let imageHeight = size.height * ratio
            let diff = imageHeight - scrollView.frame.width
            let inset = diff / 2
        
            var insets = UIEdgeInsets(top: inset * zoomScale, left: 0, bottom: inset * zoomScale, right: 0)
            let contentWidth = scrollView.contentSize.width
            if contentWidth > 0 && contentWidth < scrollView.frame.width {
                let padding = CGFloat(scrollView.frame.width - contentWidth) / 2
                insets = insets.addHorizontalInset(padding)
            }

            return insets
        }
        
        return UIEdgeInsetsZero
    }
    
    private func getInsetsForWideRectangle(size: CGSize, withZoomScale zoomScale: CGFloat = 1) -> UIEdgeInsets {
        if let scrollView = selectedImageScrollView {
            let ratio = scrollView.frame.width / size.height
            let imageWidth = size.width * ratio
            let diff = imageWidth - scrollView.frame.width
            let inset = diff / 2
        
            var insets = UIEdgeInsets(top: 0, left: inset * zoomScale, bottom: 0, right: inset * zoomScale)
            let contentHeight = scrollView.contentSize.height
            if contentHeight > 0 && contentHeight < scrollView.frame.width {
                let padding = CGFloat(scrollView.frame.width - contentHeight) / 2
                insets = insets.addVerticalInset(padding)
            }
        
            return insets
        }
        return UIEdgeInsetsZero
    }
    
    func reloadAlbum() {
        albumCollectionView?.reloadData()
    }
    
    func reloadCellAtIndexes(indexes: [Int]) {
        var indexPaths = [NSIndexPath]()
        for index in indexes {
            indexPaths.append(arrayIndexToIndexPath(index))
        }
        if indexes.count > 0 {
            UIView.performWithoutAnimation() {
                self.albumCollectionView?.reloadItemsAtIndexPaths(indexPaths)
            }
        }
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return eventHandler?.numberOfItemsInSection(section) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView,
                               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
            
            // Does not scroll to index if there is not enough content to fill the screen
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
    public func collectionView(collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = currentDisplay.CellWidthInView(collectionView)
        return CGSizeMake(size, size)
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView,
                               willDisplayCell cell: UICollectionViewCell,
                               forItemAtIndexPath indexPath: NSIndexPath) {
        if visibleCells == nil
            || indexPath.item % currentDisplay.NumberOfColumns == (currentDisplay.NumberOfColumns - 1)
            && !(visibleCells! ~= indexPath.item) {
            self.setVisibleCellsInAlbumCollectionView()
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPathToArrayIndex(indexPath)
        print("Contentoffset: \(selectedImageScrollView?.contentOffset)")
        if eventHandler?.albumImageClicked(index) == true {
            scrollToIndex(index)
            mainImageLoadIndicator?.startAnimating()
        }
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
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
        if let size = selectedImage?.image.size {
            let zoomScale = selectedImageScrollView?.zoomScale ?? 1.0
            selectedImageScrollView?.contentInset = getInsetsForSize(size, withZoomScale: zoomScale)
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
        if let mainScrollView = mainScrollView
            where scrollView.contentOffset.y < 0 {
            if userIsScrolling {
                let y = mainScrollView.contentOffset.y + scrollView.contentOffset.y
                mainScrollView.contentOffset = CGPoint(x: mainScrollView.contentOffset.x, y: y)
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
            let rowHeight = currentDisplay.CellWidthInView(albumCollectionView) + currentDisplay.Spacing
            let topVisibleRow = Int(albumCollectionView.contentOffset.y / rowHeight)
            let firstVisibleCell = topVisibleRow * currentDisplay.NumberOfColumns
            let imageViewHeight = selectedImageScrollView!.frame.height * CGFloat(1 - state.offset)
            let visibleAreaOfAlbumCollectionView = mainScrollView!.frame.height - imageViewHeight
            let numberOfVisibleRows = Int(ceil(visibleAreaOfAlbumCollectionView / rowHeight)) + 1
            let numberOfVisibleCells = numberOfVisibleRows * currentDisplay.NumberOfColumns
            let lastVisibleCell = firstVisibleCell + numberOfVisibleCells
            if (lastVisibleCell > firstVisibleCell) {
                visibleCells = firstVisibleCell..<lastVisibleCell
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
        removeMainScrollViewPanRecognizers()
        setupPanGestureRecognizerForScrollView(mainScrollView)
        setupPanGestureRecognizerForScrollView(albumCollectionView)
    }
    
    private func removeMainScrollViewPanRecognizers() {
        if let recognizers = mainScrollView?.gestureRecognizers {
            for recognizer in recognizers {
                if recognizer is UIPanGestureRecognizer {
                    mainScrollView?.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    private func setupPanGestureRecognizerForScrollView(scrollView: UIScrollView?) {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        recognizer.delegate = self
        scrollView?.addGestureRecognizer(recognizer)
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed:
            panMainScrollViewWithRecognizer(recognizer)
        case .Ended, .Cancelled, .Failed:
            panEnded()
        default: break
        }
    }
    
    private func panMainScrollViewWithRecognizer(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(mainScrollView)
        if let mainScrollView = mainScrollView {
            let old = mainScrollView.contentOffset.y
            let offset = old - translation.y
        
            mainScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            recognizer.setTranslation(CGPointZero, inView: mainScrollView)
            if let height = selectedImageView?.frame.height {
                let alpha = (offset / height) * currentDisplay.MaxImageFadeRatio
                blackOverlayView?.alpha = alpha
                rotateButton?.alpha = 1 - alpha
            }
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
                [weak self] in self?.displayViewStateForOffset(offset, withHeight: height)
            }
        } else {
            displayViewStateForOffset(offset, withHeight: height)
        }
    }
    
    private func displayViewStateForOffset(offset: CGFloat, withHeight height: CGFloat) {
        mainScrollView?.contentOffset = CGPoint(x: 0, y: offset)
        blackOverlayView?.alpha = (offset / height) * self.currentDisplay.MaxImageFadeRatio
        rotateButton?.alpha = state.rotateButtonAlpha
    }
}

extension SnapImagePickerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == albumCollectionView {
            return state == .Image
        } else if gestureRecognizer.view == mainScrollView {
            let isInImageView =
                gestureRecognizer.locationInView(selectedImageScrollView).y < selectedImageScrollView?.frame.height
            if state == .Image && isInImageView {
                return false
            }
            return true
        }
        return false
    }
}