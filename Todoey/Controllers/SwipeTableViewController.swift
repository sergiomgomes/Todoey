//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Sergio Gomes on 25/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import UIKit

class SwipeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.delete(at: index)
        }
        
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func delete(at indexPath: IndexPath){
    
    }
    
    func setupInputPopUp(alertControllerTitle: String,
                         alertActionTitle: String,
                         alertPlaceholder: String,
                         currentText: String?,
                         saveAction: @escaping (String) -> Void){
        let alert = UIAlertController(title: alertControllerTitle, message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        textField.text = currentText
        
        let action = UIAlertAction(title: alertActionTitle, style: .default) { (actionResult) in
            saveAction(textField.text ?? "")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = alertPlaceholder
            alertTextField.text = textField.text
            textField = alertTextField
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
