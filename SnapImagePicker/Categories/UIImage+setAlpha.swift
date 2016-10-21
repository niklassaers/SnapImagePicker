import UIKit

extension UIImage {
    func setAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0);
        
        let context = UIGraphicsGetCurrentContext();
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        context!.scaleBy(x: 1, y: -1);
        context!.translateBy(x: 0, y: -rect.size.height);
        
        context!.setBlendMode(.multiply);
        
        context!.setAlpha(alpha);
        
        context!.draw(self.cgImage!, in: rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }
}
