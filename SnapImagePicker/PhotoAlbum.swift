import Foundation


struct PhotoAlbum {
    let title: String
    let size: Int
    let image: UIImage?
}

extension PhotoAlbum: Equatable {}

func ==(lhs: PhotoAlbum, rhs: PhotoAlbum) -> Bool {
    return lhs.title == rhs.title
}
