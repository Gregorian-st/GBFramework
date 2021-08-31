//
//  UIView+Blur.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 30.08.2021.
//

import UIKit

extension UIView {
    
    func addBlur(alpha: CGFloat, style: UIBlurEffect.Style) {
        
        let blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        blurredEffectView.frame = self.bounds
        blurredEffectView.alpha = alpha
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurredEffectView)
    }
    
    func removeBlur() {
        
        for subview in self.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
}
