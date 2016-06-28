import UIKit

class AlbumSelectorPresenter {
    private weak var view: AlbumSelectorViewControllerProtocol?
    weak var connector: SnapImagePickerConnector?
    
    private var interactor: AlbumSelectorInteractorProtocol?
    
    private var collections: [String: [Album]] = [
        AlbumSelectorEntityGateway.CollectionNames.General: [Album](),
        AlbumSelectorEntityGateway.CollectionNames.UserDefined: [Album](),
        AlbumSelectorEntityGateway.CollectionNames.SmartAlbums: [Album]()
    ]
    
    init(view: AlbumSelectorViewControllerProtocol) {
        self.view = view
        interactor = AlbumSelectorInteractor(presenter: self)
    }
}

extension AlbumSelectorPresenter: AlbumSelectorPresenterProtocol {
    func presentAlbumPreview(collectionTitle: String, album: Album) {
        if collections[collectionTitle] != nil {
            collections[collectionTitle]!.append(album)
        }
        
        view?.display(sortAndCollapseCollections(collections))
    }
    
    // The order given in this function decides the sort order for the collections!
    private func sortAndCollapseCollections(collections: [String: [Album]]) -> [(title: String, albums: [Album])] {
        var formattedCollections = [(title: String, albums: [Album])]()
        
        if let general = collections[AlbumSelectorEntityGateway.CollectionNames.General]
           where general.count > 0 {
            formattedCollections.append((title: AlbumSelectorEntityGateway.CollectionNames.General, albums: general))
        }
        
        if let userDefined = collections[AlbumSelectorEntityGateway.CollectionNames.UserDefined]
           where userDefined.count > 0 {
            formattedCollections.append((title: AlbumSelectorEntityGateway.CollectionNames.UserDefined, albums: userDefined))
        }
        
        if let smartAlbums = collections[AlbumSelectorEntityGateway.CollectionNames.SmartAlbums]
           where smartAlbums.count > 0 {
            formattedCollections.append((title: AlbumSelectorEntityGateway.CollectionNames.SmartAlbums, albums: smartAlbums))
        }
        
        return formattedCollections
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