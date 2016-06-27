import UIKit

class SelectedImageScrollView: UIScrollView {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("Begin draggin!")
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("End draggin!)")
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("ASDf")
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
           print("ASDf")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
                print("ASDf")
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
                print("ASDf")
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
                print("ASDf")
    }

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
                print("ASDf")
    }
    
}
