import UIKit

enum Display: CustomStringConvertible {
    case Portrait
    case Landscape
    
    var Spacing: CGFloat {
        return 2
    }
    var BackgroundColor: UIColor {
        return UIColor.whiteColor()
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
    var OffsetThreshold: ClosedInterval<Double> {
        return Double(0.2)...Double(0.7)
    }
    
    var NumberOfColumns: Int {
        switch self {
        case Portrait: return 4
        case Landscape: return 8
        }
    }
    
    var SelectedImageWidthMultiplier: CGFloat {
        switch self {
        case Portrait: return 1
        case Landscape: return 0.5
        }
    }
    
    var AlbumCollectionWidthMultiplier: CGFloat {
        switch self {
        case Portrait: return 1
        case Landscape: return 1
        }
    }
        
    func CellWidthInView(collectionView: UICollectionView) -> CGFloat {
        return CellWidthInViewWithWidth(collectionView.bounds.width)
    }
    
    func CellWidthInViewWithWidth(width: CGFloat) -> CGFloat {
        return (width - (Spacing * CGFloat(NumberOfColumns - 1))) / CGFloat(NumberOfColumns)
    }
    
    var description: String {
        switch self {
        case .Portrait: return "Portrait"
        case .Landscape: return "Landscape"
        }
    }
}