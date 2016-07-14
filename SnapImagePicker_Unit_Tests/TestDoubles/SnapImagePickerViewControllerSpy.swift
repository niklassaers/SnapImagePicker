@testable import SnapImagePicker

class SnapImagePickerViewControllerSpy: SnapImagePickerViewControllerProtocol {
    var displayCount = 0
    var displayViewModel: SnapImagePickerViewModel?
    
    func display(viewModel: SnapImagePickerViewModel) {
        displayCount += 1
        displayViewModel = viewModel
    }
}
