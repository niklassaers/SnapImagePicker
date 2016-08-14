import Photos

protocol ImageLoaderProtocol: class {
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> ()) -> PHImageRequestID
    func deleteRequests(requestIds: [PHImageRequestID])
    func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: ([Int: SnapImagePickerImage]) -> ()) -> [Int: PHImageRequestID]
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult?
    func loadImageWithLocalIdentifier(identifier: String, handler: (SnapImagePickerImage -> Void))
}