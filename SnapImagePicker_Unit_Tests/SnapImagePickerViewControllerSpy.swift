@testable import SnapImagePicker

class SnapImagePickerViewControllerSpy: SnapImagePickerViewControllerProtocol {
    var displayCount = 0
    var displayViewModel: SnapImagePickerViewModel?
    
    private let delegate: SnapImagePickerViewControllerSpyDelegate?
    init(delegate: SnapImagePickerViewControllerSpyDelegate) {
        self.delegate = delegate
    }
    
    func display(viewModel: SnapImagePickerViewModel) {
        displayCount += 1
        displayViewModel = viewModel
    }
}
