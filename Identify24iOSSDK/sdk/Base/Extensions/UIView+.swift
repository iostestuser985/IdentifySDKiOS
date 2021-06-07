//
//  UIView+.swift
//  Kimlik
//
//  Created by MacBookPro on 13.02.2021.
//

import UIKit

extension UIView {
    
    public func addShadow() {
        self.layer.applyFigmaShadow(color:.black, alpha: 0.1, x: 0, y: 5, blur: 20, spread: 0)
    }
    
}
