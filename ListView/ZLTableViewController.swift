//
//  ZLTableViewController.swift
//  ListView
//
//  Created by zcz on 2024/2/28.
//

import UIKit

class ZLTableViewController: UITableViewController {
    
    var modelManager: ZListModelManager?
    
    private var selectItems: Set<String> = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        title = "title"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        let listModel = modelManager?.listModels[section]
        
        return modelManager?.listModels.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        
        let model = modelManager!.listModels[indexPath.row]
        cell.textLabel?.text = model.text 
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let model = modelManager?.listModels[indexPath.row]
        return Int(model?.level ?? "0") ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let manager = modelManager {
            let didSelectModel = manager.listModels[indexPath.row]
            if didSelectModel.belowCount == 0 {
                if let submodels = didSelectModel.openModel() {
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

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
