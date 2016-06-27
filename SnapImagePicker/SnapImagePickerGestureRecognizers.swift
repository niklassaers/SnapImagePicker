import UIKit


protocol DisplayStateDelegate: class {
    var displayState: DisplayState? { get }
}

class SnapImagePickerGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var delegate: DisplayStateDelegate?
    let shouldRecognizeInState: DisplayState
    
    init(delegate: DisplayStateDelegate, shouldRecognizeInState: DisplayState) {
        self.delegate = delegate
        self.shouldRecognizeInState = shouldRecognizeInState
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("Checing!")
//        if let state = delegate?.displayState {
//            return state == shouldRecognizeInState
//        }
        
        return true
    }
}
