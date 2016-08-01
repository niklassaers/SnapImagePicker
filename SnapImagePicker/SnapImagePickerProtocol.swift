import UIKit

public protocol SnapImagePickerProtocol {
    func initializeViewController() -> UIViewController?
    func photosAccessStatusChanged()
    
    /* Enables a custom transition animation for a navigation controller.
    *
    * If the function is called several times in a row without calling disableCustomTransitionForNavigationController
    * in between, only the navigation controller from the will have the transitioning delegate set
    *
    * Returns true/false based on whether the delegate is set or not */
    func enableCustomTransitionForNavigationController(navigationController: UINavigationController) -> Bool
    
    /* Disables a custom transition animation for a navigation controller.
    *
    * Will only remove the delegate when call is made with the same navigation controller as the last successful
    * call to enableCustomTransitionForNavigationController
    * 
    * Returns true/false based on whether the delegate is removed or not */
    func disableCustomTransitionForNavigationController(navigationController: UINavigationController) -> Bool
}
