import UIKit

protocol AlbumSelectorEntityGatewayProtocol {
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: Album -> Void)
}