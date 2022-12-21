//
//  UIImage+Extensions.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat? = nil) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let cornerRadius = cornerRadius, cornerRadius > 0 {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            UIBezierPath(roundedRect: rect, cornerRadius:cornerRadius).addClip()
            image?.draw(in: rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
