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
    private var state: DisplayState = .Image
    
    init(view: SnapImagePickerViewControllerProtocol) {
        self.view = view
    }
    
    private func display(shouldFocus: Bool = true, orientation: SnapImagePickerViewModel.Orientation = .Portrait) {
        view?.display(SnapImagePickerViewModel(albumTitle: albumType.getAlbumName(),
            mainImage: mainImage,
            albumImages: albumImages,
            displayState: state,
            selectedIndex: selectedIndex,
            shouldFocusMainImage: shouldFocus,
            orientation: orientation))
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
    func presentMainImage(image: UIImage) {
        state = .Image
        mainImage = image
        display()
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
    var displayState: DisplayState {
        return state
    }
    
    func viewWillAppear() {
        checkPhotosAccessStatus()
    }
    
    private func loadAlbum() {
        imagesWithIdentifiers = [(image: UIImage, id: String)]()
        interactor?.loadAlbumWithType(albumType, withTargetSize: CGSize(width: 64, height: 64))
    }
    
    func albumIndexClicked(index: Int) {
        if index < imagesWithIdentifiers.count {
            self.selectedIndex = index
            interactor?.loadImageWithLocalIdentifier(imagesWithIdentifiers[index].id, withTargetSize: CGSize(width: 2000, height: 2000))
        }
    }
    
    func userScrolledToState(state: DisplayState) {
        self.state = state
        display()
    }
    
    func flipImageButtonPressed() {
        if let mainImage = mainImage {
            self.mainImage = mainImage.imageRotatedByDegrees(270, flip: false)
            display(false)
        }
    }
    
    func albumTitleClicked(destinationViewController: UIViewController) {
        connector?.prepareSegueToAlbumSelector(destinationViewController)
    }
    
    func selectButtonPressed(image: UIImage, withCropRect cropRect: CGRect) {
        connector?.setChosenImage(image, withCropRect: cropRect)
    }
    
    func scrolledToOffsetRatio(ratio: Double) {
        if state == .Album && ratio < 0.7 {
            state = .Image
        } else if state == .Image && ratio > 0.2 {
            state = .Album
        }
        
        display()
    }
}