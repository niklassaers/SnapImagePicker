import Photos

protocol ImageLoaderProtocol: class {
    func loadImageFromAsset(asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: (SnapImagePickerImage) -> ()) -> PHImageRequestID
    func loadImagesFromAssets(assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: ([Int: SnapImagePickerImage]) -> ())
    func fetchAssetsFromCollectionWithType(type: AlbumType) -> PHFetchResult?
}