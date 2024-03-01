//
//  ZLTreeView.swift
//  ListView
//
//  Created by ZCZ on 2024/3/1.
//

import UIKit

class ZLTreeView: UIView {
    var modelManager: ZListModelManager? {
        didSet {
            self.tbView.reloadData()
        }
    }
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("sssssssssssss")
        setupUI()
    }
    
    func setupUI() {
        self.addSubview(tbView)
        tbView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ZLTreeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelManager?.listModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ZlTableViewTreeCell.self), for: indexPath) as! ZlTableViewTreeCell
        
        let model = modelManager!.listModels[indexPath.row]
        let level = Int(model.level) ?? 0
        cell.indentationLevel = level
    
        cell.setData(title: model.text, avater: nil, showMore: model.showMore, level: level, showUnbind: true, delegate: self)
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let manager = modelManager {
            let didSelectModel = manager.listModels[indexPath.row]
            if didSelectModel.belowCount == 0 {
                if let submodels = didSelectModel.openModel() {
                    tableView.reloadRows(at: [indexPath], with: .none)
                    manager.listModels.insert(contentsOf: submodels, at: indexPath.row + 1)
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
                let submodels = Array(manager.listModels[range])
                didSelectModel.closeWithSubmodels(submodels)
                tableView.reloadRows(at: [indexPath], with: .none)
                manager.listModels.removeSubrange(range)
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

extension ZLTreeView: ZLTableViewTreeCellProtocol {
    func pancell(_ cell: UITableViewCell, oringX: CGFloat) {
        if let indexPath = self.tbView.indexPath(for: cell), indexPath.row > 0 {
            for i in (0..<indexPath.row).reversed() {
                if let model = modelManager?.listModels[i] {
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
