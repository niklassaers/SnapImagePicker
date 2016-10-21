import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


open class SnapImagePickerViewController: UIViewController {
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
    fileprivate var selectedImage: SnapImagePickerImage? {
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
            imageGridView?.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var imageGridViewWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var blackOverlayView: UIView? {
        didSet {
            blackOverlayView?.isUserInteractionEnabled = false
            blackOverlayView?.alpha = 0.0
        }
    }

    @IBOutlet weak var mainImageLoadIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var rotateButton: UIButton?
    @IBOutlet weak var rotateButtonLeadingConstraint: NSLayoutConstraint?
    
    @IBAction func rotateButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.selectedImageRotation = self.selectedImageRotation.next()
            sender.isEnabled = false
            
            }, completion: {
                _ in sender.isEnabled = true
        })
    }
    
    open weak var delegate: SnapImagePickerDelegate?
    var eventHandler: SnapImagePickerEventHandlerProtocol?
    
    var albumTitle = L10n.allPhotosAlbumName.string {
        didSet {
            visibleCells = nil
            setupTitleButton()
        }
    }

    fileprivate var currentlySelectedIndex = 0 {
        didSet {
            scrollToIndex(currentlySelectedIndex)
        }
    }
    
    fileprivate var selectedImageRotation = UIImageOrientation.up {
        didSet {
            self.selectedImageScrollView?.transform = CGAffineTransform(rotationAngle: CGFloat(self.selectedImageRotation.toCGAffineTransformRadians()))
        }
    }
    
    fileprivate var state: DisplayState = .image {
        didSet {
            let imageInteractionEnabled = (state == .image)
            rotateButton?.isEnabled = imageInteractionEnabled
            selectedImageScrollView?.isUserInteractionEnabled = imageInteractionEnabled
            setVisibleCellsInAlbumCollectionView()
            setMainOffsetForState(state)
        }
    }
    
    fileprivate var currentDisplay = Display.portrait {
        didSet {
            if currentDisplay != oldValue {
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
    }
    
    fileprivate func setRotateButtonConstraint() {
        let ratioNotCoveredByImage = (1 - currentDisplay.SelectedImageWidthMultiplier)
        let widthNotCoveredByImage = ratioNotCoveredByImage * view.frame.width
        let selectedImageStart = widthNotCoveredByImage / 2
        
        rotateButtonLeadingConstraint?.constant = selectedImageStart + 20
    }
    
    fileprivate var visibleCells: CountableRange<Int>? {
        didSet {
            if let visibleCells = visibleCells , oldValue != visibleCells {
                let increasing = oldValue?.startIndex < visibleCells.startIndex
                eventHandler?.scrolledToCells(visibleCells, increasing: increasing)
            }
        }
    }

    fileprivate var userIsScrolling = false
    fileprivate var enqueuedBounce: (() -> Void)?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        calculateViewSizes()
        setupGestureRecognizers()
        setupTitleButton()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentDisplay = view.frame.size.displayType()
        let width = currentDisplay.CellWidthInViewWithWidth(view.bounds.width)
        eventHandler?.viewWillAppearWithCellSize(CGSize(width: width, height: width))
        
        selectedImageScrollView?.isUserInteractionEnabled = true
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setVisibleCellsInAlbumCollectionView()
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let newDisplay = size.displayType()
        if newDisplay != currentDisplay {
            let ratio = newDisplay.SelectedImageWidthMultiplier / currentDisplay.SelectedImageWidthMultiplier
            let offsetRatio = ratio * ((newDisplay == .landscape) ? 1 * 1.33 : 1 / 1.33)
            let newOffset = selectedImageScrollView!.contentOffset * offsetRatio
            coordinator.animate(alongsideTransition: {
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
                        let insets = self?.getInsetsForSize(size, withZoomScale: zoomScale) ?? UIEdgeInsets.zero
                        self?.selectedImageScrollView?.contentInset = insets
                    }
            })
        }
    }
}

extension SnapImagePickerViewController: SnapImagePickerProtocol {
    public static func initializeWithCameraRollAccess(_ cameraRollAccess: Bool) -> SnapImagePickerViewController? {
        let bundle = Bundle(for: SnapImagePickerViewController.self)
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
        delegate?.prepareForTransition()
        eventHandler?.albumTitlePressed(self.navigationController)
    }
    
    fileprivate func setupTitleButton() {
        var title = albumTitle
        if albumTitle == AlbumType.allPhotos.getAlbumName() {
            title = L10n.allPhotosAlbumName.string
        } else if albumTitle == AlbumType.favorites.getAlbumName() {
            title = L10n.favoritesAlbumName.string
        }
        let button = UIButton()
        setupTitleButtonTitle(button, withTitle: title)
        setupTitleButtonImage(button)

        button.addTarget(self, action: #selector(albumTitlePressed), for: .touchUpInside)
        
        navigationItem.titleView = button
        delegate?.setTitleView(button)
    }
    
    fileprivate func setupTitleButtonTitle(_ button: UIButton, withTitle title: String) {
        button.titleLabel?.font = SnapImagePickerTheme.font
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.setTitleColor(UIColor.init(red: 0xB8/0xFF, green: 0xB8/0xFF, blue: 0xB8/0xFF, alpha: 1), for: .highlighted)
    }
    
    fileprivate func setupTitleButtonImage(_ button: UIButton) {
        if let mainImage = UIImage(named: "icon_s_arrow_down_gray", in: Bundle(for: SnapImagePickerViewController.self), compatibleWith: nil),
            let mainCgImage = mainImage.cgImage,
            let navBarHeight = navigationController?.navigationBar.frame.height {
            let scale = mainImage.findRoundedScale(mainImage.size.height / (navBarHeight / 6))
            let scaledMainImage = UIImage(cgImage: mainCgImage, scale: scale, orientation: .up)
            let scaledHighlightedImage = scaledMainImage.setAlpha(0.3)
            
            button.setImage(scaledMainImage, for: UIControlState())
            button.setImage(scaledHighlightedImage, for: .highlighted)
            button.frame = CGRect(x: 0, y: 0, width: scaledHighlightedImage.size.width, height: scaledHighlightedImage.size.height)
            
            button.rightAlignImage(scaledHighlightedImage)
        }
    }
    
    fileprivate func calculateViewSizes() {
        if let mainScrollView = mainScrollView {
            let mainFrame = mainScrollView.frame
            let imageSizeWhenDisplayed = view.frame.width * CGFloat(currentDisplay.SelectedImageWidthMultiplier) * CGFloat(DisplayState.album.offset)
            let imageSizeWhenHidden = view.frame.width * CGFloat(currentDisplay.SelectedImageWidthMultiplier) * (1 - CGFloat(DisplayState.album.offset))
            
            mainScrollView.contentSize = CGSize(width: mainFrame.width, height: mainFrame.height + imageSizeWhenDisplayed)
            albumCollectionViewHeightConstraint?.constant = view.frame.height - imageSizeWhenHidden - currentDisplay.NavBarHeight
        }
    }
}

extension SnapImagePickerViewController: SnapImagePickerViewControllerProtocol {
    func displayMainImage(_ mainImage: SnapImagePickerImage) {
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
        
        if state != .image {
            state = .image
        }
        
        mainImageLoadIndicator?.stopAnimating()
    }
    
    fileprivate func setMainImage(_ mainImage: SnapImagePickerImage) {
        selectedImageView?.contentMode = .scaleAspectFill
        selectedImage = mainImage
        selectedImageRotation = .up
    }
    
    fileprivate func getInsetsForSize(_ size: CGSize, withZoomScale zoomScale: CGFloat = 1) -> UIEdgeInsets{
        if (size.height > size.width) {
            return getInsetsForTallRectangle(size, withZoomScale: zoomScale)
        } else {
            return getInsetsForWideRectangle(size, withZoomScale: zoomScale)
        }
    }
    
    fileprivate func getInsetsForTallRectangle(_ size: CGSize, withZoomScale zoomScale: CGFloat = 1) -> UIEdgeInsets {
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
        
        return UIEdgeInsets.zero
    }
    
    fileprivate func getInsetsForWideRectangle(_ size: CGSize, withZoomScale zoomScale: CGFloat = 1) -> UIEdgeInsets {
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
        return UIEdgeInsets.zero
    }
    
    func reloadAlbum() {
        albumCollectionView?.reloadData()
    }
    
    func reloadCellAtIndexes(_ indexes: [Int]) {
        var indexPaths = [IndexPath]()
        for index in indexes {
            if index < albumCollectionView?.numberOfItems(inSection: 0) {
                indexPaths.append(arrayIndexToIndexPath(index))
            }
        }
        if indexes.count > 0 {
            UIView.performWithoutAnimation() {
                self.albumCollectionView?.reloadItems(at: indexPaths)
            }
        }
    }
}

extension SnapImagePickerViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return eventHandler?.numberOfItemsInSection(section) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPathToArrayIndex(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image Cell", for: indexPath)
        if let imageCell = cell as? ImageCell {
            let _ = eventHandler?.presentCell(imageCell, atIndex: index)
        }
        return cell
    }
    
    fileprivate func indexPathToArrayIndex(_ indexPath: IndexPath) -> Int {
        return (indexPath as NSIndexPath).item
    }
    
    fileprivate func arrayIndexToIndexPath(_ index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
    
    fileprivate func scrollToIndex(_ index: Int) {
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
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = currentDisplay.CellWidthInView(collectionView)
        return CGSize(width: size, height: size)
    }
}

extension SnapImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        if visibleCells == nil
            || (indexPath as NSIndexPath).item % currentDisplay.NumberOfColumns == (currentDisplay.NumberOfColumns - 1)
            && !(visibleCells! ~= (indexPath as NSIndexPath).item) {
            self.setVisibleCellsInAlbumCollectionView()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPathToArrayIndex(indexPath)
        
        if eventHandler?.albumImageClicked(index) == true {
            scrollToIndex(index)
            mainImageLoadIndicator?.startAnimating()
        }
    }
}

extension SnapImagePickerViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            mainScrollViewDidScroll(scrollView)
        } else if scrollView == albumCollectionView {
            albumCollectionViewDidScroll(scrollView)
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return selectedImageView
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        userIsScrolling = false
        if scrollView == albumCollectionView && velocity.y != 0.0 && targetContentOffset.pointee.y == 0 {
            enqueuedBounce = {
                self.mainScrollView?.manuallyBounceBasedOnVelocity(velocity)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userIsScrolling = true
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)

        } else if scrollView == albumCollectionView && !decelerate {
            scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == albumCollectionView && state == .album {
            state = .album
        } else if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
        }
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.2)
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let size = selectedImage?.image.size {
            let zoomScale = selectedImageScrollView?.zoomScale ?? 1.0
            selectedImageScrollView?.contentInset = getInsetsForSize(size, withZoomScale: zoomScale)
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView == selectedImageScrollView {
            setImageGridViewAlpha(0.0)
        }
    }
}
extension SnapImagePickerViewController {
    fileprivate func mainScrollViewDidScroll(_ scrollView: UIScrollView) {
        if let albumCollectionView = albumCollectionView {
            let remainingAlbumCollectionHeight = albumCollectionView.contentSize.height - albumCollectionView.contentOffset.y
            let albumStart = albumCollectionView.frame.minY - scrollView.contentOffset.y
            let offset = scrollView.frame.height - (albumStart + remainingAlbumCollectionHeight)
            if offset > 0 && albumCollectionView.contentOffset.y - offset > 0 {
                albumCollectionView.contentOffset = CGPoint(x: 0, y: albumCollectionView.contentOffset.y - offset)
            }
        }
    }
    
    fileprivate func albumCollectionViewDidScroll(_ scrollView: UIScrollView) {
        if let mainScrollView = mainScrollView
            , scrollView.contentOffset.y < 0 {
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
    
    fileprivate func scrolledToOffsetRatio(_ ratio: Double) {
        if state == .album && ratio < currentDisplay.OffsetThreshold.upperBound {
            state = .image
        } else if state == .image && ratio > currentDisplay.OffsetThreshold.lowerBound {
            state = .album
        } else {
            setMainOffsetForState(state)
        }
    }
}

extension SnapImagePickerViewController {
    fileprivate func setVisibleCellsInAlbumCollectionView() {
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
    fileprivate func calculateOffsetToImageHeightRatio() -> Double {
        if let offset = mainScrollView?.contentOffset.y,
            let height = selectedImageScrollView?.frame.height {
            return Double((offset + currentDisplay.NavBarHeight) / height)
        }
        return 0.0
    }
    
    fileprivate func setImageGridViewAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in self?.imageGridView?.alpha = alpha
        }) 
    }
}

extension SnapImagePickerViewController {
    fileprivate func setupGestureRecognizers() {
        removeMainScrollViewPanRecognizers()
        setupPanGestureRecognizerForScrollView(mainScrollView)
        setupPanGestureRecognizerForScrollView(albumCollectionView)
    }
    
    fileprivate func removeMainScrollViewPanRecognizers() {
        if let recognizers = mainScrollView?.gestureRecognizers {
            for recognizer in recognizers {
                if recognizer is UIPanGestureRecognizer {
                    mainScrollView?.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    fileprivate func setupPanGestureRecognizerForScrollView(_ scrollView: UIScrollView?) {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        recognizer.delegate = self
        scrollView?.addGestureRecognizer(recognizer)
    }
    
    func pan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            panMainScrollViewWithRecognizer(recognizer)
        case .ended, .cancelled, .failed:
            panEnded()
        default: break
        }
    }
    
    fileprivate func panMainScrollViewWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: mainScrollView)
        if let mainScrollView = mainScrollView {
            let old = mainScrollView.contentOffset.y
            let offset = old - translation.y
        
            mainScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            recognizer.setTranslation(CGPoint.zero, in: mainScrollView)
            if let height = selectedImageView?.frame.height {
                let alpha = (offset / height) * currentDisplay.MaxImageFadeRatio
                blackOverlayView?.alpha = alpha
                rotateButton?.alpha = 1 - alpha
            }
        }
    }
    
    fileprivate func panEnded() {
        scrolledToOffsetRatio(calculateOffsetToImageHeightRatio())
    }
    
    fileprivate func setMainOffsetForState(_ state: DisplayState, animated: Bool = true) {
        if let height = selectedImageScrollView?.bounds.height {
            setMainOffsetForState(state, withHeight: height, animated: animated)
        }
    }
    
    fileprivate func setMainOffsetForState(_ state: DisplayState, withHeight height: CGFloat, animated: Bool = true) {
        let offset = (height * CGFloat(state.offset))
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in self?.displayViewStateForOffset(offset, withHeight: height)
            }) 
        } else {
            displayViewStateForOffset(offset, withHeight: height)
        }
    }
    
    fileprivate func displayViewStateForOffset(_ offset: CGFloat, withHeight height: CGFloat) {
        mainScrollView?.contentOffset = CGPoint(x: 0, y: offset)
        blackOverlayView?.alpha = (offset / height) * self.currentDisplay.MaxImageFadeRatio
        rotateButton?.alpha = state.rotateButtonAlpha
    }
}

extension SnapImagePickerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == albumCollectionView {
            return state == .image
        } else if gestureRecognizer.view == mainScrollView {
            let isInImageView =
                gestureRecognizer.location(in: selectedImageScrollView).y < selectedImageScrollView?.frame.height
            if state == .image && isInImageView {
                return false
            }
            return true
        }
        return false
    }
}
