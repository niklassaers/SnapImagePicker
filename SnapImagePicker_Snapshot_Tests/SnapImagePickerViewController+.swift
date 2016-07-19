@testable import SnapImagePicker

extension SnapImagePickerViewController {
    override func viewDidLayoutSubviews() {
        print("Main offset: \(mainScrollView!.contentOffset)")
        super.viewDidLayoutSubviews()
        viewWillAppear(false)
//      TODO:  setMainOffsetForState(self.state)
        print("Main offset after: \(mainScrollView!.contentOffset)")
    }
}