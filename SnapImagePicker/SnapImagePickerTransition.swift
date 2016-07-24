import Foundation
import UIKit

class VerticalSlideTransitionManager : NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.3
    let action: Action
    
    enum Action {
        case Push
        case Pop
    }
    
    init(action: Action) {
        self.action = action
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if action == .Push {
            push(transitionContext)
        } else {
            pop(transitionContext)
        }
    }
    
    func push(transitionContext: UIViewControllerContextTransitioning) {
        if let containerView = transitionContext.containerView(),
           let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
            containerView.addSubview(toView)
            
            let size = containerView.bounds.size
            let initalFrame = CGRect(x: CGFloat(0.0), y: -size.height, width: size.width, height: size.height)
            let finalFrame  = containerView.bounds
        
            toView.frame = initalFrame
            UIView.animateWithDuration(animationDuration,
                                       animations: { toView.frame = finalFrame },
                                       completion: { _ in transitionContext.completeTransition(true) })
        }
    }
    
    func pop(transitionContext: UIViewControllerContextTransitioning) {
        if let containerView = transitionContext.containerView(),
           let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
           let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
            
            let size = containerView.bounds.size
            let finalFrame = CGRect(x: CGFloat(0.0), y: -size.height, width: size.width, height: size.height)
            
            toView.frame = CGRect(x: CGFloat(0.0), y: 0, width: size.width, height: size.height)
            containerView.addSubview(toView)
            containerView.sendSubviewToBack(toView)
            UIView.animateWithDuration(animationDuration,
                                       animations: {fromView.frame = finalFrame},
                                       completion: { _ in transitionContext.completeTransition(true)})
        }
    }
}

public class SnapImagePickerNavigationControllerDelegate: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    public override init() {
        super.init()
    }
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (fromVC is AlbumSelectorViewController  && toVC is SnapImagePickerViewController) ||
            (fromVC is SnapImagePickerViewController && toVC is AlbumSelectorViewController)  {
            switch operation {
            case .None: return nil
            case .Push: return VerticalSlideTransitionManager(action: .Push)
            case .Pop: return VerticalSlideTransitionManager(action: .Pop)
            }
        }
        return nil
    }
}