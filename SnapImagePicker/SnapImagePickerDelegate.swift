import Foundation
import UIKit

public protocol SnapImagePickerDelegate : class {
    func setTitleView(_ titleView: UIView)
    func prepareForTransition()
}
