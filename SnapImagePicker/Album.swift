import UIKit

struct Album {
    let size: Int
    let image: UIImage
    let type: AlbumType
    var collectionName: String {
        get {
            return type.getCollectionName()
        }
    }
    var albumName: String {
        get {
            return type.getAlbumName()
        }
    }
}

enum AlbumType {
    case AllPhotos
    case Favorites
    case UserDefined(title: String)
    case SmartAlbum(title: String)
    
    struct AlbumNames {
        static let AllPhotos = "All Photos"
        static let Favorites = "Favorites"
    }
    
    func getAlbumName() -> String {
        switch self {
        case .AllPhotos: return AlbumNames.AllPhotos
        case .Favorites: return AlbumNames.Favorites
        case .UserDefined(let title): return title
        case .SmartAlbum(let title): return title
        }
    }
    
    struct CollectionNames {
        static let General = "Cameraroll"
        static let UserDefined = "Albums"
        static let SmartAlbums = "Smart Albums"
    }
    
    func getCollectionName() -> String {
        switch self {
        case .AllPhotos: return CollectionNames.General
        case .Favorites: return CollectionNames.General
        case .UserDefined(_): return CollectionNames.UserDefined
        case .SmartAlbum(_): return CollectionNames.SmartAlbums
        }
    }
}

