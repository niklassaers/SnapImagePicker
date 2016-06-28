import UIKit

class AlbumSelectorPresenter {
    private weak var view: AlbumSelectorViewControllerProtocol?
    weak var connector: SnapImagePickerConnector?
    
    private var interactor: AlbumSelectorInteractorProtocol?
    
    private var collections = [String: [Album]]()
    
    init(view: AlbumSelectorViewControllerProtocol) {
        self.view = view
        interactor = AlbumSelectorInteractor(presenter: self)
    }
}

extension AlbumSelectorPresenter: AlbumSelectorPresenterProtocol {
    func presentAlbumPreview(collectionTitle: String, album: Album) {
        var oldCollection = collections[collectionTitle]
        if oldCollection == nil {
            collections[collectionTitle] = [album]
        } else {
            oldCollection!.append(album)
            collections[collectionTitle] = oldCollection!
        }
        view?.display(collections)
    }
}

extension AlbumSelectorPresenter: AlbumSelectorEventHandler {
    func viewWillAppear() {
        interactor?.fetchAlbumPreviewsWithTargetSize(CGSize(width: 64, height: 64))
    }
    
    func albumSelected(title: String) {
        connector?.prepareSegueToImagePicker(title)
    }
}