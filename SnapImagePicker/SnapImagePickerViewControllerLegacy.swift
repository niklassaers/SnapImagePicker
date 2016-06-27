//import UIKit
//
//class SnapImagePickerViewController: UIViewController {
//    
//    private var eventHandler: SnapImagePickerEventHandlerProtocol?
//    
//    @IBOutlet weak var mainScrollView: UIScrollView?
//    @IBOutlet weak var selectedImageScrollView: UIScrollView?
//    @IBOutlet weak var selectedImageView: UIImageView?
//    @IBOutlet weak var albumCollectionView: UICollectionView?
//    @IBOutlet weak var albumSelectorView: AlbumSelectorView?
//
//    @IBOutlet weak var mainAlbumTitleButton: UIButton? {
//        didSet {
//            mainAlbumTitleButton?.titleLabel?.font = SnapImagePicker.Theme.font
//        }
//    }
//    @IBOutlet weak var nextButton: UIButton? {
//        didSet {
//            if let font = SnapImagePicker.Theme.font {
//                nextButton?.titleLabel?.font = font.fontWithSize(15)
//            }
//        }
//    }
//    
//    @IBOutlet weak var albumCollectionViewHeightConstraint: NSLayoutConstraint?
//    @IBOutlet weak var albumSelectorTopConstraint: NSLayoutConstraint?
//    @IBOutlet weak var imageAndAlbumSpacingConstraint: NSLayoutConstraint?
//    
//    var albums = [PhotoAlbum]() {
//        didSet {
//            albumSelectorView?.albums = albums
//        }
//    }
//    
//    var currentlySelectedAlbum = 0 {
//        didSet {
//            if currentlySelectedAlbum < albums.count {
//                state = .Image
//                let title = albums[currentlySelectedAlbum].title
//                loadAlbum(title)
//                mainAlbumTitleButton?.setTitle(title, forState: .Normal)
//            }
//        }
//    }
//    
//    var selectedImage: UIImage? {
//        didSet {
//            setupSelectedImageScrollView()
//        }
//    }
//    var images = [(id: String, image: UIImage)]() {
//        didSet {
//            if let albumCollectionView = albumCollectionView {
//                albumCollectionView.reloadData()
//            }
//        }
//    }
//    
//    private var state = DisplayState.Image {
//        didSet {
//            setMainOffsetFor(state)
//        }
//    }
//    
//    private var albumSelectorIsShowing: Bool {
//        return albumSelectorTopConstraint?.constant == UIConstants.TopBarHeight
//    }
//    
//    var currentlySelectedIndex = 0 {
//        didSet {
//            albumCollectionView?.reloadData()
//        }
//    }
//    
//    var interactor: AlbumInteractorInput?
//    var delegate: SnapImagePickerDelegate?
//    
//    private struct UIConstants {
//        static let Spacing = CGFloat(2)
//        static let NumberOfColumns = 4
//        static let BackgroundColor = UIColor.whiteColor()
//        static let MaxZoomScale = 5.0
//        static let CellBorderWidth = CGFloat(3.0)
//        static let TopBarHeight = CGFloat(44.0)
//        
//        static func CellWidthInView(collectionView: UICollectionView) -> CGFloat {
//            return (collectionView.bounds.width - (Spacing * CGFloat(NumberOfColumns - 1))) / CGFloat(NumberOfColumns)
//        }
//    }
//    
//    private let OffsetThreshold = CGFloat(0.35)...CGFloat(0.65)
//    enum DisplayState {
//        case Image
//        case Album
//        
//        var offset: CGFloat {
//            switch self {
//            case Image: return 0.0
//            case Album: return 0.85
//            }
//        }
//        
//        var fadeRatio: Double {
//            switch self {
//            case Image: return 0.0
//            case Album: return 0.85
//            }
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        eventHandler = SnapImagePickerPresenter(view: self)
//        
//        
//        setupSelectedImageScrollView()
//        setupAlbumCollectionView(PhotoLoader.DefaultAlbumNames.AllPhotos)
//        setupGestureRecognizers()
//        setupAlbumSelectorView()
//        setupViewSizes()
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//            [weak self] in
//            self?.interactor?.fetchAlbumPreviews()
//        }
//        
//        imageAndAlbumSpacingConstraint?.constant = UIConstants.Spacing
//        selectedImageScrollView?.userInteractionEnabled = true
//    }
//    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.Portrait
//    }
//    
//    @IBAction func acceptImageButtonPressed(sender: UIButton) {
//        if let cropRect = ImageUtilities.getBoundsOfImageVisibleInScrollView(selectedImageScrollView, imageView: selectedImageView),
//           let image = selectedImageView?.image {
//            delegate?.pickedImage(image, withBounds: cropRect)
//        }
//        dismiss()
//    }
//    
//    @IBAction func cancelButtonPressed(sender: UIButton) {
//        dismiss()
//    }
//    
//
//    
//    @IBAction func collectionsButtonClicked(sender: UIButton) {
//        if albumSelectorIsShowing {
//            hideAlbumSelectorView()
//        } else {
//            showAlbumSelectorView()
//        }
//    }
//    
//    private func dismiss() {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//}
//
//extension SnapImagePickerViewController {
//
//    private func showAlbumSelectorView() {
//        albumSelectorTopConstraint?.constant = UIConstants.TopBarHeight
//        UIView.animateWithDuration(NSTimeInterval(0.5)) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    private func hideAlbumSelectorView() {
//        albumSelectorTopConstraint?.constant = self.view.frame.height
//        UIView.animateWithDuration(NSTimeInterval(0.5)) {
//            self.view.layoutIfNeeded()
//        }
//    }
//}
//
//extension SnapImagePickerViewController {
//    private func setupSelectedImageScrollView() {
//        if let scrollView = selectedImageScrollView,
//           let imageView = selectedImageView,
//           let image = selectedImage {
//            scrollView.setZoomScale(1.0, animated: false)
//            imageView.contentMode = .ScaleAspectFit
//            imageView.image = image
//            imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
//            scrollView.contentSize = CGSize(width: imageView.bounds.width, height: imageView.bounds.height)
//            
//            let zoomScale = findZoomScale(image)
//        
//            scrollView.setZoomScale(zoomScale, animated: false)
//            scrollView.minimumZoomScale = 1.0
//            scrollView.maximumZoomScale = CGFloat(UIConstants.MaxZoomScale)
//            scrollView.delegate = self
//        }
//    }
//    
//    private func findZoomScale(image: UIImage) -> CGFloat {
//        return max(image.size.width, image.size.height)/min(image.size.width, image.size.height)
//    }
//    
//    private func setupAlbumCollectionView(title: String) {
//        if let albumCollectionView = albumCollectionView {
//            SnapImagePicker.setupAlbumViewController(self)
//            albumCollectionView.dataSource = self
//            albumCollectionView.delegate = self
//            albumCollectionView.backgroundColor = UIConstants.BackgroundColor
//            loadAlbum(title)
//        }
//    }
//    
//    private func loadAlbum(title: String) {
//        if let albumCollectionView = albumCollectionView {
//            images = [(id: String, image: UIImage)]()
//            let imageCellWidth = UIConstants.CellWidthInView(albumCollectionView)
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//                [weak self] in
//                self?.interactor?.fetchAlbum(Album_Request(title: title, size: CGSize(width: imageCellWidth, height: imageCellWidth)))
//            }
//        }
//    }
//    
//    private func setupAlbumSelectorView() {
//        if let albumSelectorView = albumSelectorView {
//            view.addSubview(albumSelectorView)
//            albumSelectorView.dataSource = albumSelectorView
//            albumSelectorView.delegate = self
//            albumSelectorView.separatorColor = UIConstants.BackgroundColor
//            albumSelectorView.albums = albums
//            
//            hideAlbumSelectorView()
//        }
//    }
//    
//    private func setupViewSizes() {
//        if let mainScrollView = mainScrollView,
//            let imageFrame = selectedImageScrollView?.frame {
//            let mainFrame = mainScrollView.frame
//            let imageSizeWhenDisplayed = imageFrame.height * CGFloat(DisplayState.Album.offset)
//            let imageSizeWhenHidden = imageFrame.height * (1 - DisplayState.Album.offset)
//            mainScrollView.contentSize = CGSize(width: mainFrame.width, height: mainFrame.height + imageSizeWhenDisplayed)
//            albumCollectionViewHeightConstraint?.constant = mainFrame.height - imageSizeWhenHidden - UIConstants.Spacing
//        }
//    }
//}
//
//extension SnapImagePickerViewController: UICollectionViewDataSource {
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return (images.count / UIConstants.NumberOfColumns) + 1
//    }
//
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let previouslyUsedImages = section * UIConstants.NumberOfColumns
//        let remainingImages = images.count - previouslyUsedImages
//        let columns = min(UIConstants.NumberOfColumns, remainingImages)
//        
//        return columns
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let index = indexPathToArrayIndex(indexPath)
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath)
//        if let imageCell = cell as? ImageCell
//           where index < images.count {
//           let image = ImageUtilities.squareImage(images[index].image)
//            
//            if index == currentlySelectedIndex {
//                imageCell.spacing = 2.0
//            } else {
//                imageCell.spacing = 0.0
//            }
//            
//            imageCell.imageView?.contentMode = .ScaleAspectFill
//            imageCell.imageView?.image = image
//            print("Cell size: \(imageCell.bounds)")
//        }
//        return cell
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let size = UIConstants.CellWidthInView(collectionView)
//        return CGSize(width: size, height: size)
//    }
//    
//    private func indexPathToArrayIndex(indexPath: NSIndexPath) -> Int {
//        return indexPath.section * UIConstants.NumberOfColumns + indexPath.row
//    }
//}
//
//extension SnapImagePickerViewController: UICollectionViewDelegate {
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        requestMainImageFromIndex(indexPathToArrayIndex(indexPath))
//    }
//    
//    private func requestMainImageFromIndex(index: Int) {
//        let size = CGSize(width: SnapImagePicker.Theme.maxImageSize, height: SnapImagePicker.Theme.maxImageSize)
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//            [weak self] in
//            if let strongSelf = self {
//                strongSelf.interactor?.fetchImage(Image_Request(id: strongSelf.images[index].id, size: size))
//            }
//        }
//        setMainOffsetFor(.Image)
//        currentlySelectedIndex = index
//    }
//}
//
//protocol AlbumViewControllerInput : class {
//    func displayAlbumImage(response: Image_Response)
//    func displayMainImage(response: Image_Response)
//    func addAlbumPreview(album: PhotoAlbum)
//}
//
//extension SnapImagePickerViewController: AlbumViewControllerInput {
//    func displayAlbumImage(response: Image_Response) {
//        images.append((id: response.id, image: response.image))
//        print("Loaded an album image!")
//        if images.count == 1 {
//            requestMainImageFromIndex(0)
//        }
//    }
//    
//    func displayMainImage(response: Image_Response) {
//        selectedImage = response.image
//    }
//    
//    func addAlbumPreview(album: PhotoAlbum) {
//        albums.append(album)
//    }
//}
//
//extension SnapImagePickerViewController: UIScrollViewDelegate {
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return selectedImageView
//    }
//}
//
//extension SnapImagePickerViewController {
//    private func setupGestureRecognizers() {
//        mainScrollView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
//        gesture.delegate = self
//        albumCollectionView?.addGestureRecognizer(gesture)
//    }
//    
//    func pan(recognizer: UIPanGestureRecognizer) {
//        switch recognizer.state {
//        case .Changed:
//            let translation = recognizer.translationInView(mainScrollView)
//            if let old = mainScrollView?.contentOffset.y
//               where old - translation.y > 0 {
//                mainScrollView?.contentOffset = CGPoint(x: 0, y: old - translation.y)
//                recognizer.setTranslation(CGPointZero, inView: mainScrollView)
//            }
//        case .Ended, .Cancelled, .Failed:
//            panEnded()
//        default: break
//        }
//    }
//    
//    private func panEnded() {
//        if let offset = mainScrollView?.contentOffset.y,
//            let height = selectedImageScrollView?.bounds.height {
//            let ratio = (height - offset) / height
//            let prevState = state
//            var offset = CGFloat(0.0)...OffsetThreshold.end
//            
//            if prevState == .Album {
//                offset = OffsetThreshold.start...CGFloat(1)
//            }
//            
//            if offset ~= ratio {
//                state = (prevState == .Image) ? .Album : .Image
//            } else {
//                state = prevState
//            }
//        }
//    }
//    
//    private func setMainOffsetFor(state: DisplayState) {
//        if let selectedImageScrollView = selectedImageScrollView,
//           let mainScrollView = mainScrollView {
//            let height = selectedImageScrollView.bounds.height
//            mainScrollView.setContentOffset(CGPoint(x: mainScrollView.contentOffset.x, y: height * CGFloat(state.offset)), animated: true)
//            
//            switch state {
//            case .Image:
//                selectedImageScrollView.userInteractionEnabled = true
//            case .Album:
//                selectedImageScrollView.userInteractionEnabled = false
//            }
//        }
//    }
//}
//
//extension SnapImagePickerViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let albumCanScrollFurtherUp = albumCollectionView?.contentOffset.y > 0
//        var userIsScrollingUpwards = false
//        
//        if let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
//            userIsScrollingUpwards = panRecognizer.translationInView(albumCollectionView).y > 0
//        }
//        
//        if userIsScrollingUpwards {
//            albumCollectionView?.bounces = false
//        } else {
//            albumCollectionView?.bounces = true
//        }
//        
//        return state == .Image || (userIsScrollingUpwards && !albumCanScrollFurtherUp)
//    }
//}
//
//extension SnapImagePickerViewController: UITableViewDelegate {
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        currentlySelectedAlbum = indexPath.row
//        hideAlbumSelectorView()
//    }
//}
//
//extension SnapImagePickerViewController: SnapImagePickerViewControllerProtocol {
//    
//}