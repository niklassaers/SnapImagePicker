import Photos

protocol ImageLoader: class {
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> Void) -> PHImageRequestID
    func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: (SnapImagePickerImage, Int) -> Void)
    func deleteRequestForId(id: PHImageRequestID)
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult?
    func clearPendingRequests()
}