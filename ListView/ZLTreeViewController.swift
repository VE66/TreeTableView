//
//  ZLTreeViewController.swift
//  ListView
//
//  Created by zcz on 2024/2/29.
//

import UIKit

class ZLTreeViewController: UIViewController {
    
    var modelManager: ZListModelManager?
    private var levelMax: [String: CGFloat] = [:]
    private var selectItems: Set<String> = Set<String>()

    lazy var tbView = {
        let tb = UITableView(frame: CGRect.zero, style: .plain)
        tb.dataSource = self
        tb.delegate = self
        tb.estimatedRowHeight = 48
        tb.rowHeight = UITableView.automaticDimension
        tb.register(ZlTableViewTreeCell.self, forCellReuseIdentifier: NSStringFromClass(ZlTableViewTreeCell.self))
        tb.backgroundColor = UIColor(red: 246/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
        tb.separatorStyle = .none
        return tb
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let treeView = ZLTreeView()
        treeView.modelManager = self.modelManager
        self.view.addSubview(treeView)
        treeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


}

extension ZLTreeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelManager?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ZlTableViewTreeCell.self), for: indexPath) as! ZlTableViewTreeCell
        
        let model = modelManager!.list[indexPath.row]
        let level = Int(model.level) ?? 0
        cell.indentationLevel = level
    
        cell.setData(title: model.text, avater: nil, showMore: model.showMore, level: level, showUnbind: true, delegate: self)
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let manager = modelManager {
            let didSelectModel = manager.list[indexPath.row]
            if didSelectModel.belowCount == 0 {
                if let submodels = didSelectModel.openModel() {
                    tableView.reloadRows(at: [indexPath], with: .none)
                    manager.list.insert(contentsOf: submodels, at: indexPath.row + 1)
                    var indexPaths: [IndexPath] = []
                    for (i, _) in submodels.enumerated() {
                        let insertIndexPath = IndexPath(row: indexPath.row + 1 + i , section: indexPath.section)
                        indexPaths.append(insertIndexPath)
                    }
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: indexPaths, with: .fade)
                    }
                }
            } else {
                let range = (indexPath.row + 1)..<(didSelectModel.belowCount+indexPath.row + 1)
                let submodels = Array(manager.list[range])
                didSelectModel.closeWithSubmodels(submodels)
                tableView.reloadRows(at: [indexPath], with: .none)
                manager.list.removeSubrange(range)
                var indexPaths: [IndexPath] = []
                for (i, _) in submodels.enumerated() {
                    let insertIndexPath = IndexPath(row: indexPath.row + 1 + i , section: indexPath.section)
                    indexPaths.append(insertIndexPath)
                }
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: indexPaths, with: .fade)
                }
            }
        }
    }

}

extension ZLTreeViewController: ZLTableViewTreeCellProtocol {
    func pancell(_ cell: UITableViewCell, oringX: CGFloat) {
        if let indexPath = self.tbView.indexPath(for: cell), indexPath.row > 0 {
            for i in (0..<indexPath.row).reversed() {
                if let model = modelManager?.list[i] {
                    if model.level != "0" {
                        let index = IndexPath(row: i, section: indexPath.section)
                        if let cell = tbView.cellForRow(at: index) as? ZlTableViewTreeCell {
                            cell.horizontalMigration(oringX)
                        }
                    } else {
                        /// 避免进入其它层级--
                        break
                    }
                }
            }
            
        }
    }
    
    func unbindAction(_ cell: UITableViewCell) {
        if let indexPath = self.tbView.indexPath(for: cell) {
            print("---- 解绑 = \(indexPath)")
        }
    }
    
    
}
