import UIKit
import Photos

class SnapImagePickerPresenter {
    private weak var view: SnapImagePickerViewControllerProtocol?
    
    var interactor: SnapImagePickerInteractorProtocol?
    weak var connector: SnapImagePickerConnectorProtocol?
    
    var albumType = AlbumType.AllPhotos {
        didSet {
            interactor?.clearPendingRequests()
            loadAlbum()
        }
    }
    
    enum RequestStatus: Equatable {
        case None
        case Deleted
        case Requested
        case Completed
        
        func isInitializedOrCompleted() -> Bool {
            switch self {
            case None, Deleted: return false
            case Requested, Completed: return true
            }
        }
    }
    
    private var mainImage: SnapImagePickerImage?
    private var requestedMainImage: String?
    private var albumSize: Int?
    private var albumImages: [(imageWrapper: SnapImagePickerImage?, status: RequestStatus)]?
    private var indexes = [String: Int]()
    private var selectedIndex = 0
    
    private var cellSize = CGSize(width: 64, height: 64)
    
    private let queueName = "com.snapsale.SnapImagePicker.AlbumImagesQueue"
    private let queue: dispatch_queue_t?
    
    init(view: SnapImagePickerViewControllerProtocol) {
        self.view = view
        queue = dispatch_queue_create("andrew.myblockarrayclass", nil)
    }
    
    private func insertAlbumImage(image: SnapImagePickerImage?, withStatus status: RequestStatus, atIndex index: Int) {
        if let queue = queue {
            dispatch_sync(queue) {
                [weak self] in self?.albumImages?[index] = (imageWrapper: image, status: status)
            }
        }
    }
}

extension SnapImagePickerPresenter {
    private func loadAlbum() {
        interactor?.loadInitialAlbum(albumType)
    }
    
    private func display() {
        view?.display(SnapImagePickerViewModel(albumTitle: albumType.getAlbumName(),
            mainImage: mainImage,
            selectedIndex: selectedIndex,
            isLoading: mainImage?.localIdentifier != requestedMainImage))
    }
}

extension SnapImagePickerPresenter {
    func photosAccessStatusChanged() {
        checkPhotosAccessStatus()
    }
    
    private func checkPhotosAccessStatus() {
        validatePhotosAccessStatus(PHPhotoLibrary.authorizationStatus())
    }
    
    private func validatePhotosAccessStatus(availability: PHAuthorizationStatus, retry: Bool = true) {
        switch availability {
        case .Restricted: fallthrough
        case .Authorized: loadAlbum()
        case .Denied:connector?.requestPhotosAccess()
        case .NotDetermined:
            if retry {
                PHPhotoLibrary.requestAuthorization() {
                    [weak self] status in self?.validatePhotosAccessStatus(status, retry: false)
                }
            } else {
                connector?.requestPhotosAccess()
            }
        }
    }
}

extension SnapImagePickerPresenter: SnapImagePickerPresenterProtocol {
    func presentInitialAlbum(image: SnapImagePickerImage, albumSize: Int) {
        mainImage = image
        requestedMainImage = image.localIdentifier
        albumImages = [(imageWrapper: SnapImagePickerImage?, status: RequestStatus)](count: albumSize,
                                                                                     repeatedValue: (imageWrapper: nil, status: RequestStatus.None))
        
        display()
    }
    
    func presentMainImage(image: SnapImagePickerImage) -> Bool {
        if image.localIdentifier == requestedMainImage {
            mainImage = image
            
            display()
            return true
        }
        
        return false
    }
    
    func presentAlbumImage(image: SnapImagePickerImage, atIndex index: Int) -> Bool {
        if index < albumImages?.count && index >= 0 {
            if albumImages?[index].status == .Deleted {
                insertAlbumImage(nil, withStatus: RequestStatus.None, atIndex: index)
            } else {
                insertAlbumImage(image, withStatus: RequestStatus.Completed, atIndex: index)
            }
            display()
            return true
        }
        
        return false
    }
    
    func deletedRequestAtIndex(index: Int, forAlbumType albumType: AlbumType) {
        print("Deleted request!")
        if albumType == self.albumType {
            insertAlbumImage(nil, withStatus: .None, atIndex: index)
        }
    }
}

extension SnapImagePickerPresenter: SnapImagePickerEventHandlerProtocol {
    func viewWillAppearWithCellSize(cellSize: CGFloat) {
        self.cellSize = CGSize(width: cellSize, height: cellSize)
        checkPhotosAccessStatus()
    }

    func albumImageClicked(index: Int) -> Bool {
        if let albumImages = albumImages
           where index < albumImages.count {
            if let localIdentifier = albumImages[index].imageWrapper?.localIdentifier {
                selectedIndex = index
                requestedMainImage = localIdentifier
                interactor?.loadImageWithLocalIdentifier(localIdentifier)
                
                display()
                return true
            }
        }
        
        return false
    }
    
    func albumTitleClicked(destinationViewController: UIViewController) {
        connector?.prepareSegueToAlbumSelector(destinationViewController)
    }

    func selectButtonPressed(image: UIImage, withImageOptions options: ImageOptions) {
        connector?.setChosenImage(image, withImageOptions: options)
    }
    
    func numberOfSectionsForNumberOfColumns(columns: Int) -> Int {
        if let albumImages = albumImages {
            return max(albumImages.count / columns, 1)
        }
        
        return 0
    }
    
    func numberOfItemsInSection(section: Int, withColumns columns: Int) -> Int {
        if let albumImages = albumImages {
            let previouslyUsedImages = section * columns
            let remainingImages = albumImages.count - previouslyUsedImages
            let columns = max(min(columns, remainingImages), 0)
        
            return columns
        }
        
        return 0
    }
    
    func presentCell(cell: ImageCell, atIndex index: Int) -> ImageCell {
        if let albumImages = albumImages
           where index < albumImages.count {
            if let imageWrapper = albumImages[index].imageWrapper {
                let image = imageWrapper.image.square()
            
                if index == selectedIndex {
                    cell.backgroundColor = SnapImagePickerConnector.Theme.color
                    cell.spacing = 2
                } else {
                    cell.spacing = 0
                }
            
                cell.imageView?.contentMode = .ScaleAspectFill
                cell.imageView?.image = image
            }
        }
        
        return cell
    }
    
    func scrolledToCells(cells: Range<Int>, increasing: Bool, fromOldRange oldCells: Range<Int>?) {
        fetchCurrentlyVisibleImages(cells)
        let numberOfUpcomingImagesToPrefetch = 100
        let numberOfPreviousImagesToPrefetch = 30
        let maxCacheSize = max(numberOfUpcomingImagesToPrefetch, numberOfPreviousImagesToPrefetch)
        prefetchImages(cells.endIndex + 1...cells.endIndex + numberOfUpcomingImagesToPrefetch)
        prefetchImages(cells.startIndex - numberOfPreviousImagesToPrefetch..<cells.startIndex)
        if increasing {
            clearPreviousImagesFrom(cells.startIndex - 2 * maxCacheSize, to: cells.startIndex - maxCacheSize)
        } else {
            clearPreviousImagesFrom(cells.endIndex + 1 + maxCacheSize, to: cells.endIndex + 2 * maxCacheSize)
        }
    }
}

extension SnapImagePickerPresenter {
    private func fetchCurrentlyVisibleImages(range: Range<Int>) {
        if let albumImages = albumImages {
            let start = max(range.startIndex, 0)
            let end = min(range.endIndex + 1, albumImages.count)
            if end > start {
                for i in start..<end {
                    if albumImages[i].status == .Deleted {
                        self.insertAlbumImage(nil, withStatus: .Requested, atIndex: i)
                    } else if !albumImages[i].status.isInitializedOrCompleted() {
                        self.insertAlbumImage(nil, withStatus: .Requested, atIndex: i)
                        interactor?.loadAlbumImageWithType(albumType, withTargetSize: cellSize, atIndex: i)
                    }
                }
            }
        }
    }
    
    private func prefetchImages(range: Range<Int>) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in
            if let albumImages = self?.albumImages {
                let start = max(range.startIndex, 0)
                let end = min(range.endIndex + 1, albumImages.count)
                if end > start {
                    for i in start..<end {
                        if albumImages[i].status == .Deleted {
                            self?.insertAlbumImage(nil, withStatus: .Requested, atIndex: i)
                        } else if !albumImages[i].status.isInitializedOrCompleted() {
                            if let strongSelf = self {
                                strongSelf.insertAlbumImage(nil, withStatus: .Requested, atIndex: i)
                                strongSelf.interactor?.loadAlbumImageWithType(strongSelf.albumType, withTargetSize: strongSelf.cellSize, atIndex: i)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func clearPreviousImagesFrom(startIndex: Int, to endIndex: Int) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            [weak self] in
            if let albumImages = self?.albumImages {
                let start = max(startIndex, 0)
                let end = min(endIndex + 1, albumImages.count)
                if end > start {
                    for i in start..<end {
                        if albumImages[i].status == .Requested {
                            if let strongSelf = self {
                                strongSelf.insertAlbumImage(nil, withStatus: .Deleted, atIndex: i)
                                strongSelf.interactor?.deleteRequestForId(i, forAlbumType: strongSelf.albumType)
                            }
                        } else if albumImages[i].status == .Completed {
                            self?.insertAlbumImage(nil, withStatus: .None, atIndex: i)
                        }
                    }
                }
            }
        }
    }
}