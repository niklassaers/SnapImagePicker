import UIKit

enum DisplayState {
    case image
    case album
        
    var offset: Double {
        switch self {
        case .image: return 0.0
        case .album: return 0.85
        }
    }
    
    var rotateButtonAlpha: CGFloat {
        switch self {
        case .image: return 1.0
        case .album: return 0.3
        }
    }
}
