//
//  ZListModelManager.swift
//  ListView
//
//  Created by zcz on 2024/2/27.
//

import UIKit
import HandyJSON
class ZListModelManager: NSObject {
    var listModels: [ListModel] = []
    init(listModels: [ListModel]) {
        self.listModels = listModels
    }
}

enum TreeTipStatus {
    case none, show, close
}

class ListModel: HandyJSON {
  
    required init() {
        
    }
 
    var text: String = ""
    var id: String = ""
    var level: String = "0"
    var belowCount: Int = 0 {
        didSet {
            self.supermodel?.belowCount += belowCount - oldValue
        }
    }
    var supermodel: ListModel?
    var submodels: [ListModel]?
    
    var showMore: TreeTipStatus = .close
    
    func openModel() -> [ListModel]? {
        guard var items = self.submodels, items.isEmpty == false else {
            return nil
        }
        self.showMore = .show
        
         items = items.map({ m in
            if m.level != "0" {
                m.supermodel = self
            }
             if let submodels = m.submodels, submodels.isEmpty == false {
                 m.showMore = .close
             } else {
                 if m.showMore == .close {
                     m.showMore = .none
                 }
             }
             return m
        })
        
        self.submodels = nil
        self.belowCount = items.count
        return items
    }
    
    func closeWithSubmodels(_ submodels: [ListModel]) {
        self.submodels = submodels
        self.belowCount = 0
        self.showMore = .close
    }
    
}
