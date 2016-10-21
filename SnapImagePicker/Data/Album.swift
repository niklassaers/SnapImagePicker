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
    case allPhotos
    case favorites
    case userDefined(title: String)
    case smartAlbum(title: String)
    
    struct AlbumNames {
        static let AllPhotos = "All Photos"
        static let Favorites = "Favorites"
    }
    
    func getAlbumName() -> String {
        switch self {
        case .allPhotos: return AlbumNames.AllPhotos
        case .favorites: return AlbumNames.Favorites
        case .userDefined(let title): return title
        case .smartAlbum(let title): return title
        }
    }
    
    struct CollectionNames {
        static let General = "Cameraroll"
        static let UserDefined = "Albums"
        static let SmartAlbums = "Smart Albums"
    }
    
    func getCollectionName() -> String {
        switch self {
        case .allPhotos: return CollectionNames.General
        case .favorites: return CollectionNames.General
        case .userDefined(_): return CollectionNames.UserDefined
        case .smartAlbum(_): return CollectionNames.SmartAlbums
        }
    }
}

extension AlbumType: Equatable {}

func ==(a: AlbumType, b: AlbumType) -> Bool {
    return a.getAlbumName() == b.getAlbumName()
}


