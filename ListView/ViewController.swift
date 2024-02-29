//
//  ViewController.swift
//  ListView
//
//  Created by zcz on 2024/1/2.
//

import UIKit
import SnapKit
import HandyJSON
import RxSwift
import RxCocoa
class ViewController: UIViewController {

    lazy var listView: UITableView = {
        let tab = UITableView.init(frame: self.view.bounds, style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.estimatedRowHeight = 45
        tab.rowHeight = UITableView.automaticDimension
        return tab
    }()
    
    private var datas: [Int] = []
    
    private let loadMoreQueue = DispatchQueue(label: "loadMore")
    
    private var scroll_up = false
    private var noData = false
    private var loadMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        setupView1()
//        addData()
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUI() {
        let button = UIButton(type: .system)
        button.setTitle("跳转", for: .normal)
        
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.top.equalToSuperview().offset(100)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        button.rx.tap.subscribe { _ in
            self.pushZLTableViewController()
        }
    }
    
    func pushZLTableViewController() {
        let path = Bundle.main.path(forResource: "model", ofType: "text") ?? ""
        if let data = NSData(contentsOfFile: path) {
            let dict = try? JSONSerialization.jsonObject(with: data as Data) as? [Any]
            if let model = [ListModel].deserialize(from: dict) as? [ListModel] {
                let mgr = ZListModelManager.init(listModels: model)
                let vc = ZLTableViewController()
                vc.modelManager = mgr
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func addData() {
        var maxIndex = 500
        let items = self.setData(maxIndex)
        self.datas = items
        listView.reloadData()
    }
    
    func setData(_ maxIndex: Int) -> [Int] {
        if maxIndex < 30 {
            return []
        }
        var items: [Int] = []
        for i in ((maxIndex - 30)...maxIndex).reversed() {
            items.insert(i, at: 0)
        }
        return items
    }
    
    func loadMoreData() {
        
        loadMoreQueue.sync(flags: .barrier) {
            loadMore = true
            var maxIndex = 5000
            if datas.isEmpty == false {
                maxIndex = datas.first!
            }
            
            print("maxIndex = \(maxIndex)")
            
            let items = self.setData(maxIndex)
            if items.isEmpty {
                noData = true
                loadMore = false
                return
            }
            var indexPaths = [IndexPath]()
            for i in 0 ..< items.count {
                let indexPath = IndexPath(row: i, section: 0)
                indexPaths.append(indexPath)
            }
                        
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
                self.datas = items + self.datas
                let bottomY = self.listView.contentSize.height - self.listView.contentOffset.y
                self.listView.performBatchUpdates {
                    self.listView.insertRows(at: indexPaths, with: UITableView.RowAnimation.top)
                } completion: { _ in
                    self.loadMore = false
                }
                let contentOff = CGPoint(x: 0, y: self.listView.contentSize.height - bottomY)
                self.listView.setContentOffset(contentOff, animated: false)
                self.loadMore = false
                UIView.setAnimationsEnabled(true)
            }
            
        }

    }
    
    func setupView1() {
        self.view.addSubview(self.listView)
        self.listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


}

extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.translation(in: self.view)
        if point.y > 0 {
            // 向上走
            self.scroll_up = true
        } else {
            self.scroll_up = false
        }

    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell_id")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell_id")
        }
        
        
        let data = datas[indexPath.row]
        cell?.textLabel?.text = "\(data)"
        if self.scroll_up, loadMore == false, noData == false, indexPath.row == 5 {
            print("cellForRowAt = \(indexPath.row)")
            self.loadMoreData()
        }
        
        return cell!
    }
    
}

