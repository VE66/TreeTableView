//
//  ZListModelManager.swift
//  ListView
//
//  Created by zcz on 2024/2/27.
//

import UIKit
import HandyJSON

protocol ZListModelManagerDelegate: AnyObject {
    
}

protocol ZlTreeListChangedProtocol: AnyObject {
    func insertRow(at indexPath: IndexPath, with indexPaths: [IndexPath])
    func deleteRow(at indexPath: IndexPath, with indexPaths: [IndexPath])
}

class ZListModelManager: NSObject {
    var list: [ListModel] = []
    
    weak var listChangedDeleagte: ZlTreeListChangedProtocol?
    weak var deleagte: ZListModelManagerDelegate?

    
    func getData(completion: @escaping ([ListModel])->Void) {
        let data = [
            [
             "text":"河北省",
             "level":"0",
             "submodels":[
                     [
                         "text":"衡水市",
                         "level":"1",
                         "submodels":[
                                 [
                                     "text":"阜城县",
                                     "level":"2",
                                     "submodels":[
                                             [
                                                 "text":"大白乡",
                                                 "level":"3",
                                                 "submodels":[
                                                         [
                                                             "text":"衡水市",
                                                             "level":"4",
                                                             "submodels":[
                                           [
                                               "text":"阜城县",
                                               "level":"5",
                                               "submodels":[
                                                       [
                                                           "text":"大白乡",
                                                           "level":"6",
                                                           ],
                                                       [
                                                           "text":"建桥乡",
                                                           "level":"6",
                                                           ],
                                                       [
                                                           "text":"古城镇",
                                                           "level":"6",
                                                           ]
                                                       ]
                                               ],
                                           [
                                               "text":"武邑县",
                                               "level":"5",
                                               ],
                                           [
                                               "text":"景县",
                                               "level":"5",
                                               ]
                                           ]
                                                             ],
                                                         [
                                                             "text":"廊坊市",
                                                             "level":"1",
                                                             "submodels":[
                                           [
                                               "text":"固安县",
                                               "level":"2",
                                               ],
                                           [
                                               "text":"三河市",
                                               "level":"2",
                                               ],
                                           [
                                               "text":"霸州市",
                                               "level":"2",
                                               ]
                                           ]
                                                             ]
                                                         ]
                                                 ],
                                             [
                                                 "text":"建桥乡",
                                                 "level":"3",
                                                 ],
                                             [
                                                 "text":"古城镇",
                                                 "level":"3",
                                                 ]
                                             ]
                                     ],
                                 [
                                     "text":"武邑县",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"景县",
                                     "level":"2",
                                     ]
                                 ]
                         ],
                     [
                         "text":"廊坊市",
                         "level":"1",
                         "submodels":[
                                 [
                                     "text":"固安县",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"三河市",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"霸州市",
                                     "level":"2",
                                     ]
                                 ]
                         ]
                     ]
             ],
            [
             "text":"山东省",
             "level":"0",
             "submodels":[
                     [
                         "text":"德州市",
                         "level":"1",
                         "submodels":[
                                 [
                                     "text":"临邑县",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"齐河县",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"平原县",
                                     "level":"2",
                                     ]
                                 ]
                         ],
                     [
                         "text":"烟台市",
                         "level":"1",
                         "submodels":[
                                 [
                                     "text":"蓬莱市",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"招远市",
                                     "level":"2",
                                     ],
                                 [
                                     "text":"海阳市",
                                     "level":"2",
                                     ]
                                 ]
                         ]
                     ]
             ],
          ]
        
        if let model = [ListModel].deserialize(from: data) as? [ListModel] {
            self.list = model
            completion(model)
        } else {
            self.list = []
            completion([])
        }
    }
    
    
    func clickItem(at indexPath: IndexPath, supperOffsetX: CGFloat? = nil) {
        let didSelectModel = self.list[indexPath.row]
        if didSelectModel.belowCount == 0 {
            if let submodels = didSelectModel.openModel(supperOffsetX) {
                self.list.insert(contentsOf: submodels, at: indexPath.row + 1)
                var indexPaths: [IndexPath] = []
                for i in 0..<submodels.count {
                    let insertIndexPath = IndexPath(row: indexPath.row + 1 + i , section: indexPath.section)
                    indexPaths.append(insertIndexPath)
                }
                listChangedDeleagte?.insertRow(at: indexPath, with: indexPaths)
            }
        } else {
            let range = (indexPath.row + 1)..<(didSelectModel.belowCount+indexPath.row + 1)
            let submodels = Array(self.list[range])
            didSelectModel.closeWithSubmodels(submodels)
            self.list.removeSubrange(range)
            var indexPaths: [IndexPath] = []
            for i in 0..<submodels.count {
                let insertIndexPath = IndexPath(row: indexPath.row + 1 + i , section: indexPath.section)
                indexPaths.append(insertIndexPath)
            }
            listChangedDeleagte?.deleteRow(at: indexPath, with: indexPaths)

        }
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
    var supperOffSetX: CGFloat?

    var belowCount: Int = 0 {
        didSet {
            self.supermodel?.belowCount += belowCount - oldValue
        }
    }
    var supermodel: ListModel?
    var submodels: [ListModel]?
    
    var showMore: TreeTipStatus = .close
    
    func openModel(_ supperOffSetX: CGFloat? = nil) -> [ListModel]? {
        guard var items = self.submodels, items.isEmpty == false else {
            return nil
        }
        self.showMore = .show
        
        let level: Int = Int(self.level) ?? 0
        
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
             
             let currentLevel = Int(m.level) ?? level + 1
             if currentLevel == level + 1 {
                 m.supperOffSetX = supperOffSetX
             } else {
                 if let supperOffSetX = supperOffSetX {
                     // 子类2级要去除上一层----使用时自己父类所以要减一层
                     m.supperOffSetX = 30 * CGFloat((currentLevel - level - 1)) + supperOffSetX
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
