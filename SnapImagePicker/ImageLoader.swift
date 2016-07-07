import Photos

protocol ImageLoader: class {
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult?
}