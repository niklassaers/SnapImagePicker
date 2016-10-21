import Foundation
import UIKit

class VerticalSlideTransitionManager : NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.3
    let action: Action
    
    enum Action {
        case push
        case pop
    }
    
    init(action: Action) {
        self.action = action
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if action == .push {
            push(transitionContext)
        } else {
            pop(transitionContext)
        }
    }
    
    func push(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            containerView.addSubview(toView)
            
            let size = containerView.bounds.size
            let initalFrame = CGRect(x: CGFloat(0.0), y: -size.height, width: size.width, height: size.height)
            let finalFrame  = containerView.bounds
        
            toView.frame = initalFrame
            UIView.animate(withDuration: animationDuration,
                                       animations: { toView.frame = finalFrame },
                                       completion: { _ in transitionContext.completeTransition(true) })
        }
    }
    
    func pop(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
           let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            
            let size = containerView.bounds.size
            let finalFrame = CGRect(x: CGFloat(0.0), y: -size.height, width: size.width, height: size.height)
            
            toView.frame = CGRect(x: CGFloat(0.0), y: 0, width: size.width, height: size.height)
            containerView.addSubview(toView)
            containerView.sendSubview(toBack: toView)
            UIView.animate(withDuration: animationDuration,
                                       animations: {fromView.frame = finalFrame},
                                       completion: { _ in transitionContext.completeTransition(true)})
        }
    }
}

open class SnapImagePickerNavigationControllerDelegate: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    public override init() {
        super.init()
    }
    
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .none: return nil
        case .push: return VerticalSlideTransitionManager(action: .push)
        case .pop: return VerticalSlideTransitionManager(action: .pop)
        }
    }
}
