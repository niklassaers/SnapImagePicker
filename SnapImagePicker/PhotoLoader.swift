import Foundation
import Photos

protocol AlbumCollectionLoader {
    func fetchAlbumCollectionWithHandler(handler: PhotoAlbum -> Void)
}

protocol AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void)
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void)
}

class PhotoLoader {
    private enum CollectionTitles: String {
        case Album = "Album"
    }
    
    private var albumCollectionFetchResults = [String: PHFetchResult]()
    private var albumCollection = [String: PhotoAlbum]()
    private var album = [UIImage]()
}

extension PhotoLoader: AlbumCollectionLoader {
    func fetchAlbumCollectionWithHandler(handler: PhotoAlbum -> Void) {
        fetch(CollectionTitles.Album, withHandler: handler)
    }
    
    private func fetch(title: CollectionTitles, withHandler handler: PhotoAlbum -> Void) {
        switch title {
        case .Album: fetchLocalPhotos(handler)
        }
    }
    
    private func fetchLocalPhotos(handler: PhotoAlbum -> Void) {
        let title = CollectionTitles.Album.rawValue
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
    
    private func getFetchResultForAlbum(title: String) -> PHFetchResult? {
        if let result = albumCollectionFetchResults[title] {
            return result
        }
        
        if let type = CollectionTitles(rawValue: title) {
            switch type {
            case .Album:
                let result = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
                albumCollectionFetchResults[title] = result
                return result
            }
        }
        
        return nil
    }
}

extension PhotoLoader: AlbumLoader {
    func fetchAlbumWithHandler(albumTitle: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        album = [UIImage]()
        if let fetchResult = getFetchResultForAlbum(albumTitle) {
            fetchResult.enumerateObjectsUsingBlock { (object: AnyObject, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let asset = object as? PHAsset {
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
                        (image: UIImage?, data: [NSObject : AnyObject]?) in
                        if let image = image {
                            self.album.append(image)
                            handler(image, asset.localIdentifier)
                        }
                    }
                }
            }
        }
    }
    
    func fetchImageFromId(id: String, withTargetSize targetSize: CGSize, handler: (UIImage, String) -> Void) {
        let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([id], options: nil)
        if let asset = fetchResult.firstObject as? PHAsset{
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: nil) {
                (image: UIImage?, data: [NSObject : AnyObject]?) in
                if let image = image {
                    self.album.append(image)
                    handler(image, asset.localIdentifier)
                }
            }
        }
    }
}