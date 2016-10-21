import UIKit

enum Display: CustomStringConvertible {
    case portrait
    case landscape
    
    var Spacing: CGFloat {
        return 2
    }
    var BackgroundColor: UIColor {
        return UIColor.white
    }
    var MaxZoomScale: CGFloat {
        return 5
    }
    var CellBorderWidth: CGFloat {
        return 2
    }
    var NavBarHeight: CGFloat {
        return 64
    }
    var MaxImageFadeRatio: CGFloat {
        return 1.2
    }
    var OffsetThreshold: ClosedRange<Double> {
        return Double(0.2)...Double(0.7)
    }
    
    var NumberOfColumns: Int {
        switch self {
        case .portrait: return 4
        case .landscape: return 8
        }
    }
    
    var SelectedImageWidthMultiplier: CGFloat {
        switch self {
        case .portrait: return 1
        case .landscape: return 0.5
        }
    }
    
    var AlbumCollectionWidthMultiplier: CGFloat {
        switch self {
        case .portrait: return 1
        case .landscape: return 1
        }
    }
        
    func CellWidthInView(_ collectionView: UICollectionView) -> CGFloat {
        return CellWidthInViewWithWidth(collectionView.bounds.width)
    }
    
    func CellWidthInViewWithWidth(_ width: CGFloat) -> CGFloat {
        return ((width - (Spacing * CGFloat(NumberOfColumns - 1))) / CGFloat(NumberOfColumns))
    }
    
    var description: String {
        switch self {
        case .portrait: return "Portrait"
        case .landscape: return "Landscape"
        }
    }
}
