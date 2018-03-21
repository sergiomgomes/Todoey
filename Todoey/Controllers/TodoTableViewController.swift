//
//  ViewController.swift
//  Todoey
//
//  Created by Sergio Gomes on 15/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import UIKit

class TodoTableViewController: UITableViewController {

    var todoItems = [Item]()
    
    let dataFilePath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("TodoItems.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTodoItems()
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        
        let item = todoItems[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK -TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
        saveTodoItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func addTodoItem(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (actionResult) in
            
            self.todoItems.append(Item(title: textField.text! != "" ? textField.text! : "New Item", done: false))

            self.saveTodoItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTodoItems(){
        let encoder = PropertyListEncoder()
        
        do{
            let data = try encoder.encode(self.todoItems)
            try data.write(to: self.dataFilePath!)
        }catch{
            print("ERROR encoding todo items array, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadTodoItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            
            do{
                self.todoItems = try decoder.decode([Item].self, from: data)
            }catch{
                 print("ERROR decoding todo items array, \(error)")
            }
        }
    }
}

