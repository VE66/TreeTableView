//
//  ZLTreeView.swift
//  ListView
//
//  Created by ZCZ on 2024/3/1.
//

import UIKit

class ZLTreeView: UIView {
        
   weak var modelManager: ZListModelManager? {
        didSet {
            modelManager?.listChangedDeleagte = self
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
        
        setupUI()
    }
    
    func setupUI() {
        self.addSubview(tbView)
        tbView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tbView.reloadData()
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
        return modelManager?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ZlTableViewTreeCell.self), for: indexPath) as! ZlTableViewTreeCell
        
        let model = modelManager!.list[indexPath.row]
        cell.setData(model: model, showUnbind: true, delegate: self)
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var offSetX: CGFloat? = nil
        if let cell = tableView.cellForRow(at: indexPath) as? ZlTableViewTreeCell {
            offSetX = cell.getCurrentOffSetX()
        }
        modelManager?.clickItem(at: indexPath, supperOffsetX: offSetX)
    }
    
 

}

extension ZLTreeView: ZLTableViewTreeCellProtocol {
    func endPanCell(_ cell: UITableViewCell) {

        if let indexPath = self.tbView.indexPath(for: cell), indexPath.row > 0, let list = modelManager?.list {
            
            let nextIndexPath = indexPath.row + 1
            if nextIndexPath < list.count {
                for i in nextIndexPath..<(list.count) {
                    let model = list[i]
                    if model.level != 0 {
                        let index = IndexPath(row: i, section: indexPath.section)
                        if let cell = tbView.cellForRow(at: index) as? ZlTableViewTreeCell {
                            cell.endPan()
                        }
                    } else {
                        /// 避免进入其它层级--
                        break
                    }
                }
            }
        }
        
    }
    
    func pancell(_ cell: UITableViewCell, oringX: CGFloat) {
        if let indexPath = self.tbView.indexPath(for: cell), indexPath.row > 0, let list = modelManager?.list {
            var lastCell: ZlTableViewTreeCell? = cell as? ZlTableViewTreeCell
            // 向上遍历 --- 只加一个 leve 0
            for i in (0..<indexPath.row).reversed() {
                let model = list[i]
                let index = IndexPath(row: i, section: indexPath.section)
                if let cell = tbView.cellForRow(at: index) as? ZlTableViewTreeCell {
                    cell.horizontalMigration(oringX)
                }
                /// 避免进入其它层级-- 只做一次level 为0
                if model.level == 0 {
                    break
                }
                
            }
            
            // 向下遍历
            let nextIndexPath = indexPath.row + 1
            if nextIndexPath < list.count {
                for i in nextIndexPath..<(list.count) {
                    let model = list[i]
                    if model.level != 0 {
                        let index = IndexPath(row: i, section: indexPath.section)
                        if let cell = tbView.cellForRow(at: index) as? ZlTableViewTreeCell {
                            cell.horizontalMigration(oringX)
                            lastCell = cell
                        }
                    } else {
                        /// 避免进入其它层级--
                        break
                    }
                }
            }
            
            if let lastCell = lastCell {
                lastCell.showScrollIndicator(show: true, oringX: oringX)
            }
        }
    }
    
    func unbindAction(_ cell: UITableViewCell) {
        if let indexPath = self.tbView.indexPath(for: cell) {
            print("---- 解绑 = \(indexPath)")
        }
    }
    
}

extension ZLTreeView: ZlTreeListChangedProtocol {
    func insertRow(at indexPath: IndexPath, with indexPaths: [IndexPath]) {
        self.tbView.performBatchUpdates {
            self.tbView.insertRows(at: indexPaths, with: .fade)
        }
        let index = indexPath.row - 1
        let model = self.modelManager?.list[indexPath.row]
        if index >= 0 {
            let newIndexPath = IndexPath(row: index, section: 0)
            model?.supperOffSetX = getUpLevelContentOffX(newIndexPath, with: model?.level ?? 0)
        }
        // 更新角标
        self.tbView.reloadRows(at: [indexPath], with: .none)
    }
    
    func getUpLevelContentOffX(_ indexPath: IndexPath, with level: Int) -> CGFloat? {
        if let manager = modelManager {
            if indexPath.row < manager.list.count{
                for i in (0...indexPath.row).reversed() {
                    let model = manager.list[i]
                    let curretLevel = model.level
                    if curretLevel == level - 1, let cell = self.tbView.cellForRow(at: IndexPath(row: i, section: 0)) as? ZlTableViewTreeCell {
                        return cell.getCurrentOffSetX()
                    }

                }
            }
        }
        return nil
    }
    
    func deleteRow(at indexPath: IndexPath, with indexPaths: [IndexPath]) {
        self.tbView.performBatchUpdates {
            self.tbView.deleteRows(at: indexPaths, with: .fade)
        }
        
        let index = indexPath.row - 1
        let model = self.modelManager?.list[indexPath.row]
        if index >= 0 {
            let newIndexPath = IndexPath(row: index, section: 0)
            model?.supperOffSetX = getUpLevelContentOffX(newIndexPath, with: model?.level ?? 0)
        }
        // 更新角标
        self.tbView.reloadRows(at: [indexPath], with: .none)
    }
}
