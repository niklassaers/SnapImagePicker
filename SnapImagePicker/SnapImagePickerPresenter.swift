import UIKit
import Photos

class SnapImagePickerPresenter {
    private weak var view: SnapImagePickerViewControllerProtocol?
    
    var interactor: SnapImagePickerInteractorProtocol?
    weak var connector: SnapImagePickerConnectorProtocol?
    
    var albumType = AlbumType.AllPhotos
    private var mainImage: UIImage?
    private var imagesWithIdentifiers = [(image: UIImage, id: String)]()
    private var albumImages: [UIImage] {
        var images = [UIImage]()
        for (image, _) in imagesWithIdentifiers {
            images.append(image)
        }
        return images
    }
    
    private var selectedIndex = 0
    private var rotation = CGFloat(0)
    private var cellSize = CGSize(width: 64, height: 64)
    
    init(view: SnapImagePickerViewControllerProtocol) {
        self.view = view
    }
    
    private func display(shouldFocus: Bool = true) {
        view?.display(SnapImagePickerViewModel(albumTitle: albumType.getAlbumName(),
            mainImage: mainImage,
            albumImages: albumImages,
            selectedIndex: selectedIndex))
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
    func presentMainImage(image: UIImage, withLocalIdentifier identifier: String) {
        if identifier == imagesWithIdentifiers[selectedIndex].id {
            mainImage = image
            display()
        }
    }
    
    func presentAlbumImage(image: UIImage, id: String) {
        imagesWithIdentifiers.append((image: image, id: id))
        if imagesWithIdentifiers.count == 1 {
            interactor?.loadImageWithLocalIdentifier(id, withTargetSize: CGSize(width: 2000, height: 2000))
        }
        display()
    }
}

extension SnapImagePickerPresenter: SnapImagePickerEventHandlerProtocol {
    func viewWillAppearWithCellSize(cellSize: CGFloat) {
        self.cellSize = CGSize(width: cellSize, height: cellSize)
        checkPhotosAccessStatus()
    }
    
    private func loadAlbum() {
        imagesWithIdentifiers = [(image: UIImage, id: String)]()
        interactor?.loadAlbumWithType(albumType, withTargetSize: cellSize)
    }
    
    func albumIndexClicked(index: Int) {
        if index < imagesWithIdentifiers.count {
            selectedIndex = index
            interactor?.loadImageWithLocalIdentifier(imagesWithIdentifiers[index].id, withTargetSize: CGSize(width: 2000, height: 2000))
        }
    }
    
    func albumTitleClicked(destinationViewController: UIViewController) {
        connector?.prepareSegueToAlbumSelector(destinationViewController)
    }
    
    func selectButtonPressed(image: UIImage, withImageOptions options: ImageOptions) {
        connector?.setChosenImage(image, withImageOptions: options)
    }
}