//
//  CategoriesTableViewController.swift
//  Todoey
//
//  Created by Sergio Gomes on 22/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoriesTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 70
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let category = self.categories?[indexPath.row] else{
            fatalError("Categories are nil")
        }
        
        guard let color = UIColor(hexString: category.backgroundColor) else{
            fatalError("Color does not exist")
        }
        
        cell.textLabel?.text = category.name
        cell.backgroundColor = color        
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        
        //add long gesture recognize
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        cell.addGestureRecognizer(longGesture)
        
        return cell
    }

    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems"{
            let destinationVC = segue.destination as! TodoTableViewController
            
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = self.categories?[indexPath.row]
            }
        }
    }
    
    override func delete(at indexPath: IndexPath){
        if let category = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(category)
                }
            }catch{
                print("Error trying to delete category \(error)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table data manipulation methods
    func save(category: Category){
        
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        self.categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        setupInputPopUp(
            alertControllerTitle: "Add New Category",
            alertActionTitle: "Add Category",
            alertPlaceholder: "Create New Item",
            currentText: "",
            saveAction: {
                (categoryText) in
                let newCategory = Category()
                newCategory.name = categoryText != "" ? categoryText : "New Category"
                newCategory.backgroundColor = UIColor.randomFlat.hexValue()
                
                self.save(category: newCategory)
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
            
            guard let category = self.categories?[pressedIndexPath.row] else {
                fatalError("Non existing item!")
            }
            
            setupInputPopUp(
                alertControllerTitle: "Edit Todoey Category",
                alertActionTitle: "Edit Category",
                alertPlaceholder: "",
                currentText: category.name,
                saveAction: {
                    (categoryText) in
                    
                    do{
                        try self.realm.write {
                            category.name = categoryText
                        }
                    }catch{
                        print("Error editing category: \(error)")
                    }
                    
                    self.tableView.reloadData()
            })
        }
    }
}
