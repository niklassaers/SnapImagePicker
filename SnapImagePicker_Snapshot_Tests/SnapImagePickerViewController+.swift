@testable import SnapImagePicker
import UIKit

extension SnapImagePickerViewController {
    override func viewDidLayoutSubviews() {
        self.currentDisplay = view.frame.size.displayType()
        self.calculateViewSizes()
        super.viewDidLayoutSubviews()
        setMainOffsetForState(state, animated: false)
    }
}