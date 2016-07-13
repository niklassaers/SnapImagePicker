@testable import SnapImagePicker
import UIKit

extension SnapImagePickerViewController {
    override func viewDidLayoutSubviews() {
        self.currentDisplay = view.frame.size.displayType()
        let offset = mainScrollView?.contentOffset
        print("Offset is: \(offset)")
        self.calculateViewSizes()
        mainScrollView?.setContentOffset(offset!, animated: false)
    }
    
    func disableMainScrollView() {
        mainScrollView?.directionalLockEnabled = true
        mainScrollView?.scrollEnabled = false
    }
}


extension SnapImagePickerViewController {
    
}