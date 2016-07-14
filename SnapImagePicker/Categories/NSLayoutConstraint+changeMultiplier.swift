import UIKit

extension NSLayoutConstraint {
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: self.firstItem,
            attribute: self.firstAttribute,
            relatedBy: self.relation,
            toItem: self.secondItem,
            attribute: self.secondAttribute,
            multiplier: multiplier,
            constant: self.constant)
        
        newConstraint.priority = self.priority
        
        NSLayoutConstraint.deactivateConstraints([self])
        NSLayoutConstraint.activateConstraints([newConstraint])
        
        return newConstraint
    }
}