//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sampath Kumar Lam on 24/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeCellViewController {

    var categoriesArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Todoey"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.rowHeight = 80.0
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let categoryCount = categoriesArray.count
        let category = categoriesArray[indexPath.row]
        cell.textLabel?.text = categoryCount != 0 ?  categoriesArray[indexPath.row].name : "No Categories Added Yet"
        cell.backgroundColor = UIColor(hexString: category.bgColor ?? "#5856D6")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
            destinationVC.selectedCategoryColor = categoriesArray[indexPath.row].bgColor ?? "#5856D6"
        }
    }
    
    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let hexString = UIColor.randomFlat().hexValue()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if textField.text != ""{
                let category = Category(context: self.context)
                category.name = textField.text!
                category.bgColor = hexString
                self.categoriesArray.append(category)
                self.saveCategories()
                //action.isEnabled = true
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type your category..."
            print(alertTextField.text!)

            textField = alertTextField
        }
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func saveCategories(){
        do{
            try context.save()
        }catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        
        do{
            categoriesArray = try context.fetch(request)
        }catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(categoriesArray[indexPath.row])
        categoriesArray.remove(at: indexPath.row)
        saveCategories()
    }
}
