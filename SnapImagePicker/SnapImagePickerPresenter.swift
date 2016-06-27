import UIKit

class SnapImagePickerPresenter {
    private weak var view: SnapImagePickerViewControllerProtocol?
    private var interactor: SnapImagePickerInteractorProtocol?
    
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
        interactor = SnapImagePickerInteractor(presenter: self)
    }
    
    private func display() {
        view?.display(SnapImagePickerViewModel(mainImage: mainImage,
                      albumImages: albumImages,
                      displayState: state,
                      selectedIndex: selectedIndex))
    }
}

extension SnapImagePickerPresenter: SnapImagePickerPresenterProtocol {
    func presentMainImage(image: UIImage) {
        mainImage = image
        state = .Image
        display()
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
        interactor?.loadAlbumWithLocalIdentifier(SnapImagePickerEntityGateway.AlbumNames.AllPhotos, withTargetSize: CGSize(width: 64, height: 64))
    }
    
    func albumIndexClicked(index: Int) {
        if index < imagesWithIdentifiers.count {
            self.selectedIndex = index
            interactor?.loadImageWithLocalIdentifier(imagesWithIdentifiers[index].id, withTargetSize: CGSize(width: 2000, height: 2000))
            display()
        }
    }
    
    func userScrolledToState(state: DisplayState) {
        self.state = state
        display()
    }
}