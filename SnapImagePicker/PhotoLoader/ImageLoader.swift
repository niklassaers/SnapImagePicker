import Photos

protocol ImageLoaderProtocol: class {
    func loadImageFromAsset(_ asset: PHAsset, isPreview: Bool, withPreviewSize previewSize: CGSize , handler: @escaping (SnapImagePickerImage) -> ()) -> PHImageRequestID
    func deleteRequests(_ requestIds: [PHImageRequestID])
    func loadImagesFromAssets(_ assets: [Int: PHAsset], withTargetSize targetSize: CGSize, handler: @escaping ([Int: SnapImagePickerImage]) -> ()) -> [Int: PHImageRequestID]
    func fetchAssetsFromCollectionWithType(_ type: AlbumType) -> PHFetchResult<PHAsset>?
    func loadImageWithLocalIdentifier(_ identifier: String, handler: @escaping ((SnapImagePickerImage) -> Void))
}
