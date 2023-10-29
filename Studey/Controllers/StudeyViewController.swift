//
//  StudeyViewController.swift
//  Studey
//
//  Created by Dhandeep  Singh on 29/10/23.
//

import UIKit
import CoreData

class StudeyViewController: UITableViewController {
    
    var topicList = [Topic]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Categoryy? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK: - TableView Data Source Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath)
        
        let topic = topicList[indexPath.row]
        
        cell.textLabel?.text = topic.title
        
        cell.accessoryType = topic.done == true ? .checkmark : .none
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methdod
    
    //toggling checkmarks:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        topicList[indexPath.row].done = !topicList[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let datePicker = UIDatePicker()
        
        let alert = UIAlertController(title: "Add Topic", message: "", preferredStyle: .alert)
        
        // Add a text field for the title
        alert.addTextField { (titleTextField) in
            titleTextField.placeholder = "Title"
            textField = titleTextField
        }
        
        // Add a text field that uses a DatePicker for the deadline
        alert.addTextField { (deadlineTextField) in
            deadlineTextField.placeholder = "Deadline"
            deadlineTextField.inputView = datePicker
            datePicker.datePickerMode = .dateAndTime // Choose the appropriate mode
        }
        
        // Create an "Add Item" action
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the "Add Item" button on our UIAlertController
            guard let title = textField.text else {
                return // Make sure there's a title
            }
            
            let selectedDate = datePicker.date

            let newTopic = Topic(context: self.context)
            newTopic.title = title
            newTopic.done = false
            newTopic.deadline = selectedDate
            
            self.topicList.append(newTopic)
            self.saveItems()
        }
        
        // Add the "Add Item" action to the alert
        alert.addAction(addAction)
        
        // Present the alert
        present(alert, animated: true)
    }
    
    
    
    //MARK: - Model Manipulation Method
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Topic> = Topic.fetchRequest(), predicate: NSPredicate? = nil) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            topicList = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
}


//MARK: - Search Bar Methods
extension StudeyViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Topic> = Topic.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

