import UIKit

class AlbumSelectorPresenter {
    fileprivate weak var view: AlbumSelectorViewControllerProtocol?
    weak var connector: SnapImagePickerConnectorProtocol?
    
    var interactor: AlbumSelectorInteractorProtocol?
    
    fileprivate var collections: [String: [Album]] = [
        AlbumType.CollectionNames.General: [Album](),
        AlbumType.CollectionNames.UserDefined: [Album](),
        AlbumType.CollectionNames.SmartAlbums: [Album]()
    ]
    
    init(view: AlbumSelectorViewControllerProtocol) {
        self.view = view
    }
}

extension AlbumSelectorPresenter: AlbumSelectorPresenterProtocol {
    func presentAlbumPreview(_ album: Album) {
        let collectionTitle = album.collectionName
        
        if collections[collectionTitle] != nil {
            collections[collectionTitle]!.append(album)
        }
        
        view?.display(sortAndCollapseCollections(collections))
    }
    
    // The order given in this function decides the sort order for the collections!
    fileprivate func sortAndCollapseCollections(_ collections: [String: [Album]]) -> [(title: String, albums: [Album])] {
        var formattedCollections = [(title: String, albums: [Album])]()
        
        if let general = collections[AlbumType.CollectionNames.General]
           , general.count > 0 {
            formattedCollections.append((title: AlbumType.CollectionNames.General, albums: general))
        }
        
        if let userDefined = collections[AlbumType.CollectionNames.UserDefined]
           , userDefined.count > 0 {
            formattedCollections.append((title: AlbumType.CollectionNames.UserDefined, albums: userDefined))
        }
        
        if let smartAlbums = collections[AlbumType.CollectionNames.SmartAlbums]
           , smartAlbums.count > 0 {
            formattedCollections.append((title: AlbumType.CollectionNames.SmartAlbums, albums: smartAlbums))
        }
        
        return formattedCollections
    }
}

extension AlbumSelectorPresenter: AlbumSelectorEventHandler {
    func viewWillAppear() {
        interactor?.fetchAlbumPreviewsWithTargetSize(CGSize(width: 64, height: 64))
    }
    
    func albumClicked(_ albumType: AlbumType, inNavigationController navigationController: UINavigationController?) {
        connector?.segueToImagePicker(albumType, inNavigationController: navigationController)
    }
}
