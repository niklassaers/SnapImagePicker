import Foundation
import Photos

protocol AlbumCollectionLoader {
    func fetchAlbumCollectionWithHandler(handler: PhotoAlbum -> Void)
}

protocol AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, handler: UIImage -> Void)
}
class PhotoLoader {
    private enum CollectionTitles: String {
        case Local = "Local Photos"
        case ICloud = "iCloud Photos"
    }
    
    private var albumCollectionFetchResults = [String: PHFetchResult]()
    private var albumCollection = [String: PhotoAlbum]()
    private var album = [UIImage]()
}

extension PhotoLoader: AlbumCollectionLoader {
    func fetchAlbumCollectionWithHandler(handler: PhotoAlbum -> Void) {
        fetch(CollectionTitles.Local, withHandler: handler)
        fetch(CollectionTitles.ICloud, withHandler: handler)
    }
    
    private func fetch(title: CollectionTitles, withHandler handler: PhotoAlbum -> Void) {
        switch title {
        case .Local: fetchLocalPhotos(handler)
        case .ICloud: fetchICloudPhotos(handler)
        }
    }
    
    private func fetchLocalPhotos(handler: PhotoAlbum -> Void) {
        let title = CollectionTitles.Local.rawValue
        if let localPhotos = getFetchResultForAlbum(title),
           let firstImageAsset = localPhotos.firstObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(firstImageAsset,
                targetSize: CGSize(),
                contentMode: .Default,
                options: nil) {
                    [weak self] (image: UIImage?, data: [NSObject : AnyObject]?) in
                    let album = PhotoAlbum(title: title,
                                           size: localPhotos.count,
                                           image: image)
                    self?.albumCollection[title] = album
                    handler(album)
            }
            
        }
    }
    
    private func fetchICloudPhotos(handler: PhotoAlbum -> Void) {
        let title = CollectionTitles.ICloud.rawValue
        let album = PhotoAlbum(title: title, size: 0, image: nil)
        self.albumCollection[title] = album
        handler(album)
    }
    
    private func getFetchResultForAlbum(title: String) -> PHFetchResult? {
        if let result = albumCollectionFetchResults[title] {
            return result
        }
        
        if let type = CollectionTitles(rawValue: title) {
            switch type {
            case .Local:
                let result = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
                albumCollectionFetchResults[title] = result
                return result
            case .ICloud: return nil
            }
        }
        
        return nil
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, handler: UIImage -> Void) {
        album = [UIImage]()
        if let fetchResult = getFetchResultForAlbum(albumTitle) {
            fetchResult.enumerateObjectsUsingBlock { (object: AnyObject, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let asset = object as? PHAsset {
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(), contentMode: .Default, options: nil) {
                        (image: UIImage?, data: [NSObject : AnyObject]?) in
                        if let image = image {
                            self.album.append(image)
                            handler(image)
                        }
                    }
                }
            }
        }
    }
}