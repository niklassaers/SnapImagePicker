import Photos

protocol ImageLoader: class {
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> Void) -> PHImageRequestID
    func deleteRequestForId(id: PHImageRequestID)
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult?
    func clearPendingRequests()
}