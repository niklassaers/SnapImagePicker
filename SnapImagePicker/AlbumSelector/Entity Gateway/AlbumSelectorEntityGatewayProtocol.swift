import UIKit

protocol AlbumSelectorEntityGatewayProtocol {
    func fetchAlbumPreviewsWithTargetSize(_ targetSize: CGSize, handler: @escaping (Album) -> Void)
}
