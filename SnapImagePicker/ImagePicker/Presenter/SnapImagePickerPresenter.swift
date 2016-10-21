import UIKit
import Photos

class SnapImagePickerPresenter {
    fileprivate weak var view: SnapImagePickerViewControllerProtocol?
    
    var interactor: SnapImagePickerInteractorProtocol?
    var connector: SnapImagePickerConnectorProtocol?
  
    var albumType = AlbumType.allPhotos {
        didSet {
            view?.albumTitle = albumType.getAlbumName()
            if albumType != oldValue {
                loadAlbum()
            }
        }
    }
    
    fileprivate let prefetchSize = 20
    
    fileprivate var albumSize = 0
    fileprivate var requestedMainImage = 0
    fileprivate var cellSize = CGSize(width: 64, height: 64)
    fileprivate var images = [Int: SnapImagePickerImage]()
    fileprivate var currentRange: CountableRange<Int>?
    fileprivate var viewIsReady = false
    fileprivate var selectedIndex = 0
    fileprivate var _cameraRollAvailable = false {
        didSet {
            connector?.cameraRollAvailable = _cameraRollAvailable
        }
    }
  
    init(view: SnapImagePickerViewControllerProtocol, cameraRollAccess: Bool) {
        self.view = view
        _cameraRollAvailable = cameraRollAccess
        connector = SnapImagePickerConnector(presenter: self, cameraRollAvailable: cameraRollAccess)
    }
}

extension SnapImagePickerPresenter: SnapImagePickerPresenterProtocol {
    func presentAlbum(_ album: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int) {
        if album == albumType {
            self.albumSize = albumSize
            view?.displayMainImage(mainImage)
            view?.reloadAlbum()
            viewIsReady = true
        }
    }
    
    func presentMainImage(_ image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        if !_cameraRollAvailable {
            return
        }
        
        if album == albumType {
            view?.displayMainImage(image)
        }
    }
    
    func presentAlbumImages(_ results: [Int: SnapImagePickerImage], fromAlbum album: AlbumType) {
        if !_cameraRollAvailable {
            return
        }
        
        if album == albumType {
            var indexes = [Int]()
            for (index, image) in results {
                if let currentRange = currentRange , currentRange.contains(index) {
                    if images[index] == nil || images[index]!.image.size.width < image.image.size.width {
                        images[index] = image
                        indexes.append(index)
                    }
                }
            }
            if viewIsReady {
                view?.reloadCellAtIndexes(indexes)
            }
        }
    }
}

extension SnapImagePickerPresenter: SnapImagePickerEventHandlerProtocol {
    var cameraRollAccess: Bool {
        get {
            return _cameraRollAvailable
        }
        set {
            _cameraRollAvailable = newValue
            loadAlbum()
        }
    }
    fileprivate func loadAlbum() {
        images = [Int: SnapImagePickerImage]()
        currentRange = nil
        selectedIndex = 0
        viewIsReady = false
        if cameraRollAccess {
            interactor?.loadAlbum(albumType)
        }
    }
    
    func viewWillAppearWithCellSize(_ cellSize: CGSize) {
        self.cellSize = CGSize(width: cellSize.width * 2, height: cellSize.height * 2)
        
        if let image = images[selectedIndex] {
            view?.displayMainImage(image)
        } else {
            loadAlbum()
        }
    }

    func albumImageClicked(_ index: Int) -> Bool {
        if cameraRollAccess && index < albumSize  && index != selectedIndex {
            if let image = images[index] {
                view?.displayMainImage(image)
                interactor?.loadMainImageWithLocalIdentifier(image.localIdentifier, fromAlbum: albumType)
            } else {
                interactor?.loadMainImageFromAlbum(albumType, atIndex: index)
            }
            let oldSelectedIndex = selectedIndex
            selectedIndex = index
            let indexes = [oldSelectedIndex, index]
            view?.reloadCellAtIndexes(indexes)
            
            return true
        } else {
            return false
        }
    }

    func albumTitlePressed(_ navigationController: UINavigationController?) {
        if cameraRollAccess {
            connector?.segueToAlbumSelector(navigationController)
        }
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        if section == 0 {
            return albumSize
        }
        
        return 0
    }
    

    func presentCell(_ cell: ImageCell, atIndex index: Int) -> ImageCell {
        if let image = images[index] {
            if index == selectedIndex {
                cell.backgroundColor = SnapImagePickerTheme.color
                cell.spacing = 2
            } else {
                cell.spacing = 0
            }

            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = image.image
        }
        
        return cell
    }
    
    func scrolledToCells(_ range: CountableRange<Int>, increasing: Bool) {
        var toBeRemoved: CountableRange<Int>? = nil
        var toBeFetched = range

        if let oldRange = currentRange , span(range) == span(oldRange) {
            if increasing {
                toBeRemoved = findPrecedingElementsOfRange(range, other: oldRange)
                toBeFetched = findTrailingElementsOfRange(oldRange, other: range)
            } else {
                toBeRemoved = findTrailingElementsOfRange(range, other: oldRange)
                toBeFetched = findPrecedingElementsOfRange(oldRange, other: range)
            }
        }
        
        if let toBeRemoved = toBeRemoved {
            for i in toBeRemoved {
                images.removeValue(forKey: i)
            }
        }
        
        if cameraRollAccess {
            interactor?.loadAlbumImagesFromAlbum(albumType, inRange: toBeFetched, withTargetSize: cellSize)
            if let toBeRemoved = toBeRemoved {
                interactor?.deleteImageRequestsInRange(toBeRemoved)
            }
            currentRange = range
        }
    }
}
