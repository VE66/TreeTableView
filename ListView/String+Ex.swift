//
//  String+Ex.swift
//  ListView
//
//  Created by zcz on 2024/3/5.
//

import UIKit

extension String {
    /// 截取规定下标之前的字符串
    /// - Parameter index: index
    func vh_subStringTo(index: Int) -> String {
        let temporaryString = self
        let temporaryIndex = temporaryString.index(temporaryString.startIndex, offsetBy: index)
        return String(temporaryString[...temporaryIndex])
        
    }
    
    /// 截取规定下标之后的字符串
    /// - Parameter index: index
    func vh_subStringFrom(index: Int) -> String {
        let temporaryString: String = self
        let temporaryIndex = temporaryString.index(temporaryString.startIndex, offsetBy: index)
        return String(temporaryString[temporaryIndex...])
    }
}
