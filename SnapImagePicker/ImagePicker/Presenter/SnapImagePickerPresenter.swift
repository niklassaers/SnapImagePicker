import UIKit
import Photos

class SnapImagePickerPresenter {
    private weak var view: SnapImagePickerViewControllerProtocol?
    
    var interactor: SnapImagePickerInteractorProtocol?
    weak var connector: SnapImagePickerConnectorProtocol?
  
    var albumType = AlbumType.AllPhotos {
        didSet {
            loadAlbum()
        }
    }
    
    private var albumSize = 0
    private var requestedMainImage = 0
    private var cellSize = CGSize(width: 64, height: 64)
    private var images = [Int: SnapImagePickerImage]()
    private var currentRange: Range<Int>?
    private var viewIsReady = false
    private var selectedIndex = 0
  
    init(view: SnapImagePickerViewControllerProtocol) {
        self.view = view
    }
}

extension SnapImagePickerPresenter {
    private func loadAlbum() {
        viewIsReady = false
        interactor?.loadAlbum(albumType)
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
        case .Denied:
            connector?.requestPhotosAccess()
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
    func presentAlbum(image: SnapImagePickerImage, albumSize: Int) {
        self.albumSize = albumSize
        view?.displayMainImage(image)
        view?.albumTitle = albumType.getAlbumName()
        view?.reloadAlbum()
        viewIsReady = true
    }
    
    func presentMainImage(image: SnapImagePickerImage) {
        view?.displayMainImage(image)
    }
    
    func presentAlbumImage(image: SnapImagePickerImage, atIndex index: Int) {
        if let currentRange = currentRange where currentRange.contains(index) {
            if images[index] != nil {
                print("GOT AN IMAGE WHERE I ALREADY HAVE ONE AT \(index)")
            }
            images[index] = image
            if viewIsReady {
                view?.reloadCellAtIndex(index)
            }
        }
    }
}

extension SnapImagePickerPresenter: SnapImagePickerEventHandlerProtocol {
    func viewWillAppearWithCellSize(cellSize: CGFloat) {
        self.cellSize = CGSize(width: cellSize, height: cellSize)
        checkPhotosAccessStatus()
    }

    func albumImageClicked(index: Int) {
        print("CLicked on index \(index)")
        if index < albumSize {
            if let image = images[index] {
                view?.displayMainImage(image)
            }
            let oldSelectedIndex = selectedIndex
            selectedIndex = index
            interactor?.loadMainImageFromAlbum(albumType, atIndex: index)
            view?.reloadCellAtIndex(oldSelectedIndex)
            view?.reloadCellAtIndex(index)
            print("Image at index \(index): \(images[index])")
        }
    }

    func albumTitleClicked(destinationViewController: UIViewController) {
        connector?.prepareSegueToAlbumSelector(destinationViewController)
    }

    func selectButtonPressed(image: UIImage, withImageOptions options: ImageOptions) {
        connector?.setImage(image, withImageOptions: options)
    }

    func numberOfSectionsForNumberOfColumns(columns: Int) -> Int {
        let sections = Int(ceil(Double(albumSize) / Double(columns)))
        return sections
    }

    func numberOfItemsInSection(section: Int, withColumns columns: Int) -> Int {
        let previouslyUsedImages = section * columns
        let remainingImages = albumSize - previouslyUsedImages
        let columns = max(min(columns, remainingImages), 0)
        
        return columns
    }
    

    func presentCell(cell: ImageCell, atIndex index: Int) -> ImageCell {
        if let image = images[index] {
            if index == selectedIndex {
                cell.backgroundColor = SnapImagePicker.Theme.color
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
            images.removeValueForKey(i)
        }
        
        interactor?.loadAlbumImagesFromAlbum(albumType, inRange: toBeFetched)
        currentRange = range
    }

    func dismiss() {
        connector?.dismiss()
    }
}