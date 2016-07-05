import Photos

protocol ImageLoader: class {
    func fetchPhotosFromCollectionWithType(type: AlbumType) -> PHFetchResult?
}