//
//  UIColor+.swift
//  Popcorn
//
//  Created by 홍정민 on 10/8/24.
//

import UIKit

extension UIColor {
    static let white = UIColor.init(rgb: 0xFFFFFF)
    static let black = UIColor.init(rgb: 0x000000)
    static let pointRed = UIColor.init(rgb: 0xFC2125)
    static let lightBlack = UIColor.init(rgb: 0x1B1B1E)
    
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
     }
}


