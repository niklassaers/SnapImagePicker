import UIKit

protocol AlbumSelectorEntityGatewayProtocol {
    func fetchAlbumPreviewsWithTargetSize(targetSize: CGSize, handler: (String, Album) -> Void)
}