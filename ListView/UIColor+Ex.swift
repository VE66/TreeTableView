//
//  UIColor+Ex.swift
//  ListView
//
//  Created by zcz on 2024/3/5.
//

import UIKit

extension UIColor {
    convenience init(hex string: String, alpha: CGFloat = 1) {
        var hex = string.hasPrefix("#") ? String(string.dropFirst()) : string
        guard hex.count == 3 || hex.count == 6 || hex.count == 8 else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
        
        var a: CGFloat = alpha
        
        if hex.count == 8 {
            let alphaHex = hex.vh_subStringTo(index: 1)
            guard let alphaCode = Int(alphaHex, radix: 16) else {
                self.init(white: 1.0, alpha: 0.0)
                return
            }
            a = CGFloat((alphaCode) & 0xFF) / 255.0
            
            hex = hex.vh_subStringFrom(index: 2)
        }
        
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
      
        guard let intCode = Int(hex, radix: 16) else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
      
        self.init(
            red: CGFloat((intCode >> 16) & 0xFF) / 255.0,
            green: CGFloat((intCode >> 8) & 0xFF) / 255.0,
            blue: CGFloat((intCode) & 0xFF) / 255.0, alpha: a)
    }
}
