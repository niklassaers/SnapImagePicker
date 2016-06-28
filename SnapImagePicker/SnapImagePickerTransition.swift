import Foundation
import UIKit

class SlideTransitionManager : NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.3
    let direction: Direction
    
    enum Direction {
        case Upwards
        case Downwards
        
        func getInitialFrame(size: CGSize) -> CGRect {
            switch self {
            case .Upwards: return CGRect(x: CGFloat(0.0), y: size.height, width: size.width, height: size.height)
            case .Downwards: return CGRect(x: CGFloat(0.0), y: -size.height, width: size.width, height: size.height)
            }
        }
    }
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let containerView = transitionContext.containerView(),
           let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
            containerView.addSubview(toView)
            
            let finalFrame  = containerView.bounds
            let initalFrame = direction.getInitialFrame(finalFrame.size)
        
            toView.frame = initalFrame
            UIView.animateWithDuration(animationDuration,
                                       animations: { toView.frame = finalFrame },
                                       completion: { _ in transitionContext.completeTransition(true) })
        }
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .None: return nil
        case .Push: return SlideTransitionManager(direction: .Downwards)
        case .Pop: return SlideTransitionManager(direction: .Upwards)
        }
    }
}