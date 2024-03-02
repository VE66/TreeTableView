//
//  ZLTreeViewController.swift
//  ListView
//
//  Created by zcz on 2024/2/29.
//

import UIKit

class ZLTreeViewController: UIViewController {
    
    lazy var modelManager: ZListModelManager = {
        let manager = ZListModelManager()
        manager.deleagte = self
        return manager
    }()
    private var levelMax: [String: CGFloat] = [:]
    private var selectItems: Set<String> = Set<String>()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
       
    }
    
    func loadData() {
        modelManager.getData { lists in
            if lists.isEmpty == false {
                self.setDataView()
            } else {
                
            }
        }
    }
    
    func setDataView() {
        let treeView = ZLTreeView()
        treeView.modelManager = self.modelManager
        self.view.addSubview(treeView)
        treeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


}

extension ZLTreeViewController: ZListModelManagerDelegate {
    
}
