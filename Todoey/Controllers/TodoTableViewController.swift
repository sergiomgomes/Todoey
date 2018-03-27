//
//  ViewController.swift
//  Todoey
//
//  Created by Sergio Gomes on 15/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoTableViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    
    var selectedCategory: Category?{
        didSet{
            loadTodoItems()
        }
    }
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 70
    }
    
    //Loaded up just before the user see's anything on the screen
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.backgroundColor else{
            fatalError("Selected Category is nil")
        }
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - NavBar setup methods
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else{
            fatalError("Navigation Controller does not exist!")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else{
            fatalError("Color does not exist!")
        }
        
        let constrastColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = constrastColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : constrastColor]
        
        searchBar.barTintColor = navBarColor
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let item = todoItems?[indexPath.row] else{
            fatalError("Item is nil")
        }
        
        guard let color = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) else{
            fatalError("Color cannot be darken because its nil")
        }
        
        let constrastColor = ContrastColorOf(color, returnFlat: true)
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        cell.tintColor = constrastColor
        cell.backgroundColor = color
        cell.textLabel?.textColor = constrastColor
        
        //add long gesture recognize
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        cell.addGestureRecognizer(longGesture)

        return cell
    }
    
    //MARK -TableView Delegate Methods
    override func delete(at indexPath: IndexPath){
        if let item = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(item)
                }
            }catch{
                print("Error trying to delete item \(error)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving item state")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func addTodoItem(_ sender: UIBarButtonItem) {
        setupInputPopUp(
            alertControllerTitle: "Add New Todoey Item",
            alertActionTitle: "Add Item",
            alertPlaceholder: "Create New Item",
            currentText: "",
            saveAction: {
                (itemText) in
                let newItem = Item()
                newItem.title = itemText != "" ? itemText : "New Item"
                
                self.save(item: newItem)
        })
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == UIGestureRecognizerState.began {
            print("UIGestureRecognizerStateEnded")
            
            let longPressedLocation = sender.location(in: self.tableView)
            
            guard let pressedIndexPath = self.tableView.indexPathForRow(at: longPressedLocation) else{
                fatalError("Index Path at location pressed does not exist")
            }
            
            guard let item = self.todoItems?[pressedIndexPath.row] else {
                fatalError("Non existing item!")
            }
            
            setupInputPopUp(
                alertControllerTitle: "Edit Todoey Item",
                alertActionTitle: "Edit Item",
                alertPlaceholder: "",
                currentText: item.title,
                saveAction: {
                    (itemText) in
                    
                    do{
                        try self.realm.write {
                            item.title = itemText
                        }
                    }catch{
                        print("Error editing item: \(error)")
                    }
                    
                    self.tableView.reloadData()
            })
        }
    }
    
    //MARK: - Model Manipulation Section
    
    func save(item: Item){
        do{
            try self.realm.write {
                if let currentCategory = self.selectedCategory{
                    currentCategory.items.append(item)
                }
            }
        }catch{
            print("Error saving item \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadTodoItems(){
        
        self.todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods
extension TodoTableViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadTodoItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

