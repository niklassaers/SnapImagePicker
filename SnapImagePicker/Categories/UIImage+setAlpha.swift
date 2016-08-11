import UIKit

extension UIImage {
    func setAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0);
        
        let context = UIGraphicsGetCurrentContext();
        let rect = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -rect.size.height);
        
        CGContextSetBlendMode(context, .Multiply);
        
        CGContextSetAlpha(context, alpha);
        
        CGContextDrawImage(context, rect, self.CGImage);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}