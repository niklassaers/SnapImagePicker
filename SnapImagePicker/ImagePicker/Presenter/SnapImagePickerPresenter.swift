import UIKit
import Photos

class SnapImagePickerPresenter {
    private weak var view: SnapImagePickerViewControllerProtocol?
    
    var interactor: SnapImagePickerInteractorProtocol?
    var connector: SnapImagePickerConnectorProtocol?
  
    var albumType = AlbumType.AllPhotos {
        didSet {
            view?.albumTitle = albumType.getAlbumName()
            if albumType != oldValue {
                loadAlbum()
            }
        }
    }
    
    private var albumSize = 0
    private var requestedMainImage = 0
    private var cellSize = CGSize(width: 64, height: 64)
    private var images = [Int: SnapImagePickerImage]()
    private var currentRange: Range<Int>?
    private var viewIsReady = false
    private var selectedIndex = 0
    private var _cameraRollAvailable = false
  
    init(view: SnapImagePickerViewControllerProtocol) {
        self.view = view
        connector = SnapImagePickerConnector(presenter: self)
    }
}

extension SnapImagePickerPresenter: SnapImagePickerPresenterProtocol {
    func presentAlbum(album: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int) {
        if album == albumType {
            self.albumSize = albumSize
            view?.displayMainImage(mainImage)
            view?.reloadAlbum()
            viewIsReady = true
        }
    }
    
    func presentMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        if !_cameraRollAvailable {
            return
        }
        
        if album == albumType {
            view?.displayMainImage(image)
        }
    }
    
    func presentAlbumImages(results: [Int: SnapImagePickerImage], fromAlbum album: AlbumType) {
        if !_cameraRollAvailable {
            return
        }
        
        if album == albumType {
            var indexes = [Int]()
            for (index, image) in results {
                if let currentRange = currentRange where currentRange.contains(index) {
                    images[index] = image
                    indexes.append(index)
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
    private func loadAlbum() {
        images = [Int: SnapImagePickerImage]()
        currentRange = nil
        viewIsReady = false
        if cameraRollAccess {
            interactor?.loadAlbum(albumType)
        }
    }
    
    func viewWillAppearWithCellSize(cellSize: CGSize) {
        self.cellSize = cellSize
        
        if let image = images[selectedIndex] {
            view?.displayMainImage(image)
        } else {
            loadAlbum()
        }
    }

    func albumImageClicked(index: Int) -> Bool {
        if cameraRollAccess && index < albumSize  && index != selectedIndex {
            if let image = images[index] {
                view?.displayMainImage(image)
            }
            let oldSelectedIndex = selectedIndex
            selectedIndex = index
            interactor?.loadMainImageFromAlbum(albumType, atIndex: index)
            let indexes = [oldSelectedIndex, index]
            view?.reloadCellAtIndexes(indexes)
            
            return true
        } else {
            return false
        }
    }

    func albumTitlePressed(navigationController: UINavigationController?) {
        if cameraRollAccess {
            connector?.segueToAlbumSelector(navigationController)
        }
    }

    func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return albumSize
        }
        return 0
    }
    

    func presentCell(cell: ImageCell, atIndex index: Int) -> ImageCell {
        if let image = images[index] {
            if index == selectedIndex {
                cell.backgroundColor = SnapImagePickerTheme.color
                cell.spacing = 2
            } else {
                cell.spacing = 0
            }

            cell.imageView?.contentMode = .ScaleAspectFit
            cell.imageView?.image = image.image.square()
        }
        
        return cell
    }
    
    func scrolledToCells(range: Range<Int>, increasing: Bool) {
        var toBeRemoved = 0...0
        var toBeFetched = range

        if let oldRange = currentRange where span(range) == span(oldRange) {
            if increasing {
                toBeRemoved = findPrecedingElementsOfRange(range, other: oldRange)
                toBeFetched = findTrailingElementsOfRange(oldRange, other: range)
            } else {
                toBeRemoved = findTrailingElementsOfRange(range, other: oldRange)
                toBeFetched = findPrecedingElementsOfRange(oldRange, other: range)
            }
        }
        
        for i in toBeRemoved {
            interactor?.deleteImageRequestsInRange(toBeRemoved)
            images.removeValueForKey(i)
        }
        
        if cameraRollAccess {
            interactor?.loadAlbumImagesFromAlbum(albumType, inRange: toBeFetched, withTargetSize: cellSize)
            currentRange = range
        }
    }
}