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
    
    func openModel() -> [ListModel]? {
        var items = self.submodels

        
         items = items?.map({ m in
            if m.level != "0" {
                m.supermodel = self
            }
             return m
        })
        
        
        self.submodels = nil
        self.belowCount = items?.count ?? 0
        return items
    }
    
    func closeWithSubmodels(_ submodels: [ListModel]) {
        self.submodels = submodels
        self.belowCount = 0
    }
    
}
