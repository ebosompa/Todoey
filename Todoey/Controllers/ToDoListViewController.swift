//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeCellTableViewController {
    
    let realm = try! Realm()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //var itemArray = [Item]()
    var todoItems : Results<Item>?
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
//    for CoreData
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        
        
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
//Using userdefaults
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
//            itemArray = items
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        if let colorHex = selectedCategory?.hexValue{
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            
            if let navBarColor = UIColor(hexString: colorHex){
                
                //next five lines added to allow navigation bar to enter top part of iphone screen
                let bar = UINavigationBarAppearance()
                bar.backgroundColor = navBarColor
                navBar.standardAppearance = bar
                navBar.compactAppearance = bar
                navBar.scrollEdgeAppearance = bar
                
                navBar.backgroundColor = navBarColor
                title = selectedCategory!.name
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.backgroundColor = UIColor(hexString: "#FFFFFF")
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            }
            
        }
        
    }
    
//MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory?.hexValue ?? "#000000")?.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(todoItems!.count) )) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        } else{
            cell.textLabel?.text = "Nothing Here"
        }
        
        
        
        
        return cell
        
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        //deleting
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        //updating in CoreData
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        //todoItems?[indexPath.row].done = !todoItems?[indexPath.row].done
        
        //self.saveItems()
        
        //Updating realm
        if let item = todoItems?[indexPath.row]{
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("error updating")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //action after add item is pressed

            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch  {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
            
            //newItem.parentCategory = self.selectedCategory
            //self.itemArray.append(newItem)
            //self.saveItems()
        }
        

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type Here"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //Saving in CoreData
//    func saveItems() {
//        do{
//            try context.save()
//        }catch{
//            print("Error saving context, \(error)")
//        }
//
//        tableView.reloadData()
//    }
    
    
    //Saving in Realm
    func saveItems() {
        do{
            try realm.write{
                realm.add(todoItems!)
            }
        }catch{
            print("Error saving in realm, \(error)")
        }

        tableView.reloadData()
    }
    
    //loadItems in CoreData
    
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate{
//            request.predicate =  NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
//        } else{
//            request.predicate = categoryPredicate
//        }
//
//
//        do{
//            itemArray = try context.fetch(request)
//        } catch{
//            print("Error fetching data from context, \(error)")
//        }
//
//        tableView.reloadData()
//    }
    
    func loadItems() {
        //todoItems = selectedCategory?.items.filter("title LIKE[c] '*'")
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row]{
            do {
                try realm.write{
                    realm.delete(itemToDelete)
                }
            } catch  {
                print("Error deleting")
            }
        }
        
    }
}

//MARK: - Search Bar Methods using CoreData

//extension ToDoListViewController: UISearchBarDelegate{
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0{
//            loadItems()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//
//        }
//    }
//
//
//}

//MARK: - Search Bar Methods using Realm

extension ToDoListViewController: UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }


}

