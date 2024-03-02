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
        let level = Int(model.level) ?? 0
        cell.indentationLevel = level
    
        cell.setData(title: model.text, avater: nil, showMore: model.showMore, level: level, showUnbind: true, delegate: self)
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelManager?.clickItem(at: indexPath)
    }

}

extension ZLTreeView: ZLTableViewTreeCellProtocol {
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

extension ZLTreeView: ZlTreeListChangedProtocol {
    func insertRow(at indexPath: IndexPath, with indexPaths: [IndexPath]) {
        self.tbView.performBatchUpdates {
            self.tbView.insertRows(at: indexPaths, with: .fade)
        }
        // 更新角标
        self.tbView.reloadRows(at: [indexPath], with: .none)
    }
    
    func deleteRow(at indexPath: IndexPath, with indexPaths: [IndexPath]) {
        self.tbView.performBatchUpdates {
            self.tbView.deleteRows(at: indexPaths, with: .fade)
        }
        // 更新角标
        self.tbView.reloadRows(at: [indexPath], with: .none)
    }
}
