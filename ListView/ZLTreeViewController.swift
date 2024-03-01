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
        tb.register(TableViewTreeCell.self, forCellReuseIdentifier: NSStringFromClass(TableViewTreeCell.self))
        tb.backgroundColor = UIColor(red: 246/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
        tb.separatorStyle = .none
        return tb
    }()
    
    lazy var scrView = {
        let scr = UIScrollView()
        scr.showsVerticalScrollIndicator = false
        scr.backgroundColor = UIColor.clear
        scr.contentSize = self.view.bounds.size
        return scr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.addSubview(scrView)
//        scrView.snp.makeConstraints { make in
//            make.width.equalTo(self.view.bounds.width)
//            make.height.equalToSuperview()
//            make.top.bottom.equalToSuperview()
//        }
        self.view.addSubview(tbView)
        tbView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view.frame.origin.y)
        }
    }


}

extension ZLTreeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelManager?.listModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TableViewTreeCell.self), for: indexPath) as! TableViewTreeCell
        
        let model = modelManager!.listModels[indexPath.row]
        let level = Int(model.level) ?? 0
        cell.indentationLevel = level
        cell.exceedWidth = { [weak self] width in
            self?.exceedTableViewWidth(width)
        }
        cell.setData(title: model.text, avater: nil, showMore: model.showMore, level: level, showUnbind: true, delegate: self)
        return cell
    }
    
    func exceedTableViewWidth(_ width: CGFloat) {
        var contentSize = scrView.contentSize
        if width > contentSize.width {
            contentSize.width = width
        } else {
            if width < self.view.bounds.width {
                contentSize.width = self.view.bounds.width
            }
        }
//        tbView.contentSize = contentSize
        tbView.snp.updateConstraints { make in
            make.width.equalTo(contentSize.width)
        }
        scrView.contentSize = contentSize
//        self.view.layoutIfNeeded()
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

extension ZLTreeViewController: TableViewTreeCellProtocol {
    func pancell(_ cell: UITableViewCell, oringX: CGFloat) {
        if let indexPath = self.tbView.indexPath(for: cell), indexPath.row > 0 {
            for i in (0..<indexPath.row).reversed() {
                if let model = modelManager?.listModels[i] {
                    if model.level != "0" {
                        let index = IndexPath(row: i, section: indexPath.section)
                        if let cell = tbView.cellForRow(at: index) as? TableViewTreeCell {
                            cell.horizontalMigration(oringX)
                        }
                    } else {
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
