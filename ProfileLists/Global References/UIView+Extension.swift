//
//  UIView+Extension.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 8/1/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setGradientBackground(color: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor(named: "Gray")?.cgColor, color.cgColor, UIColor(named: "Gray")?.cgColor]
        gradientLayer.locations = [0.0, 0.2, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.setNeedsLayout()
    }
}
