//
//  TodosTableViewController.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 10/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import UIKit
import CoreData

//TODO: use marks
class TodosTableViewController: UITableViewController {
    
    public var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryDatabaseIfNeeded()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListElement", for: indexPath)
        
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = "description: \(task.description)"
        cell.detailTextLabel?.text = "when: \(task.date)"
        
        //cell.imageView?.image = UIImage(systemName: "checkmark.seal.fill")

      
        return cell
    }
 
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
}


// structures code better
// database managment
extension TodosTableViewController  {
    private func queryDatabaseIfNeeded() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        do {
            let count = try context.count(for: request)
            // "poor optimatization"
            // better solution will be to:
            // 1. Prefetch data (not all) on application start
            // 2. later (while scrolling) prefetch other data
            if self.tasks.count < count {
                populateTasksFromDatabase(request: request, context: context)
            }
        } catch {
            print("Error")
        }
    }
    
    // fetches data from the databse
    private func populateTasksFromDatabase(request: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext) {
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            tasks = []
            
            for data in result as! [NSManagedObject] {
                print(data)
                
                let task = Task(
                    title: data.value(forKey: "title") as! String,
                    description: data.value(forKey: "details") as! String,
                    date: data.value(forKey: "date") as! String,
                    imageName: "Apple")
                tasks.append(task)
            }
        } catch {
            print("Failed")
        }
    }
    
    private func deleteRowFromDatabase(with Index: Int) {
        //TODO: implement me
    }
    
    private func markTaskAsDoneInDatabase(with Index: Int) {
        //TODO: implement me
    }
}


// encapsulates custom actions
// for rows
extension TodosTableViewController {

    // iOS 10 and below
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.tasks.remove(at: indexPath.row)
            self.deleteRowFromDatabase(with: indexPath.row)
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        
        
        let markCompletedAction = UITableViewRowAction(style: .normal, title: "Completed") { (action, indexPath) in
            self.markTaskAsDoneInDatabase(with: indexPath.row)
        }
        markCompletedAction.backgroundColor = .green
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            // peform segueue
//            self.markTaskAsDoneInDatabase(with: indexPath.row)
        }
        editAction.backgroundColor = .orange
        
        return [markCompletedAction, editAction, deleteAction]
    }
    
    // iOS 11 and greater support
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        return nil
    }

    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, handler) in
            
            self.tasks.remove(at: indexPath.row)
            self.deleteRowFromDatabase(with: indexPath.row)
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        
        let markCompletedAction = UIContextualAction(style: .normal, title: "Completed") { (action, view, handler) in
            self.markTaskAsDoneInDatabase(with: indexPath.row)
        }
        markCompletedAction.backgroundColor = .green
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            // peform segueue
            self.markTaskAsDoneInDatabase(with: indexPath.row)
            self.tableView.reloadData()
        }
        editAction.backgroundColor = .orange
        
        
        let configuration = UISwipeActionsConfiguration(actions: [markCompletedAction, editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}
