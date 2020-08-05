//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ebo Sompa Dennis on 7/21/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

//CoreData was used with DataModel.xcdatamodeld
//import CoreData



class CategoryViewController: SwipeCellTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        
        let navBarColor = UIColor(hexString: "#1D9BF6")
        
        navBar.backgroundColor = navBarColor
        
        //next five lines added to allow navigation bar to enter top part of iphone screen
        let bar = UINavigationBarAppearance()
        bar.backgroundColor = navBarColor
        navBar.standardAppearance = bar
        navBar.compactAppearance = bar
        navBar.scrollEdgeAppearance = bar
        
        navBar.tintColor = ContrastColorOf(navBarColor!, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor!, returnFlat: true)]
        
    }
    
    //MARK: - Tableview DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let categoryName = categoryArray?[indexPath.row].name ?? "No Categories Exist Yet"
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let categoryColor = categoryArray?[indexPath.row].hexValue{
            cell.backgroundColor = UIColor(hexString: categoryColor)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }else{
            cell.backgroundColor = UIColor.randomFlat()
        }
        
        cell.textLabel?.text = categoryName
        
        
        return cell
        
    }

    //MARK: - Tableview Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            
        }
    }
    

    //MARK: - Data Manipulation Methods

    //Save to context with Coredata
    
//    func saveCategories() {
//        do{
//            try context.save()
//        }catch{
//            print("Error saving context, \(error)")
//        }
//
//        tableView.reloadData()
//    }
    
    
    //saving with Realm
    func save(category: Category) {
        
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving context, \(error)")
        }

        tableView.reloadData()
    }
//    Load Categories with Coredata
//    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
//        do{
//            categoryArray = try context.fetch(request)
//        } catch{
//            print("Error fetching data from context, \(error)")
//        }
//
//        tableView.reloadData()
//    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error deleting")
            }
        }
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //action after add category is pressed
        
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.hexValue = UIColor.randomFlat().hexValue()
            
            //categoryArray is of type Results<Category> which updates automatically
            //self.categoryArray.append(newCategory)
            self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type Here"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}





