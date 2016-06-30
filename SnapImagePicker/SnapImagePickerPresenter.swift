import UIKit

class SnapImagePickerPresenter {
    private weak var view: SnapImagePickerViewControllerProtocol?
    private var interactor: SnapImagePickerInteractorProtocol?
    
    weak var connector: SnapImagePickerConnectorProtocol?
    
    var albumTitle = PhotoLoader.AlbumNames.AllPhotos
    private var mainImage: UIImage? {
        didSet {
            display()
        }
    }
    private var imagesWithIdentifiers = [(image: UIImage, id: String)]() {
        didSet {
            display()
        }
    }
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
        interactor = SnapImagePickerInteractor(presenter: self)
    }
    
    private func display() {
        view?.display(SnapImagePickerViewModel(albumTitle: albumTitle,
            mainImage: mainImage,
            albumImages: albumImages,
            displayState: state,
            selectedIndex: selectedIndex))
    }
}

extension SnapImagePickerPresenter: SnapImagePickerPresenterProtocol {
    func presentMainImage(image: UIImage) {
        state = .Image
        mainImage = image
    }
    
    func presentAlbumImage(image: UIImage, id: String) {
        imagesWithIdentifiers.append((image: image, id: id))
        if imagesWithIdentifiers.count == 1 {
            interactor?.loadImageWithLocalIdentifier(id, withTargetSize: CGSize(width: 2000, height: 2000))
        }
    }
}

extension SnapImagePickerPresenter: SnapImagePickerEventHandlerProtocol {
    var displayState: DisplayState {
        return state
    }
    
    func viewWillAppear() {
        loadAlbum()
    }
    
    private func loadAlbum() {
        imagesWithIdentifiers = [(image: UIImage, id: String)]()
        interactor?.loadAlbumWithLocalIdentifier(albumTitle, withTargetSize: CGSize(width: 64, height: 64))
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