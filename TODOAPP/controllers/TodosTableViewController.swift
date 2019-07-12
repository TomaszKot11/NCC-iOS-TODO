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
//TODO: write tests
class TodosTableViewController: UITableViewController {
    
    public var tasks: [Task] = []
    private var currentlySelectedTask: Task?

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
        
        if task.isDone {
            cell.imageView?.image = UIImage(systemName: "checkmark.seal.fill")
        }
      
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
                let task = Task(
                    title: data.value(forKey: "title") as! String,
                    description: data.value(forKey: "details") as! String,
                    date: data.value(forKey: "date") as! String,
                    isDone: data.value(forKey: "isDone") as! Bool,
                    uuid: data.value(forKey: "uuid") as! String)
                
                tasks.append(task)
            }
        } catch {
            print("Failed")
        }
    }
    
    private func deleteRowFromDatabase(with task: Task) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", task.uuid)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let firstResult = try results.first as? NSManagedObject {
                context.delete(firstResult)
                return true;
            }
            
        } catch let error as NSError {
         print(error)
         return false
        }
        
        return false
    }
    
    private func markTaskAsDoneInDatabase(with task: Task) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
       
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", task.uuid)
        do {
            let results = try context.fetch(fetchRequest)
            if let firstResult = results.first as? NSManagedObject {
                firstResult.setValue(true, forKey: "isDone")
            }
            
            //TODO: do we need this here?
            do {
                try context.save()
                return true
//                self.tableView.reloadData()
            } catch let error as NSError {
                print(error)
                return false
            }
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailedTaskScreenSegue" {
            if let addTaskViewController = segue.destination as? AddTaskViewController, let selectedTask = currentlySelectedTask {
                addTaskViewController.initialIsDoneValue = selectedTask.isDone
                addTaskViewController.initialDescriptionValue = selectedTask.description
                addTaskViewController.initialTitleValue = selectedTask.title
                addTaskViewController.initialDateValue = selectedTask.date
                addTaskViewController.currentTask = selectedTask
            }
        }
    }
}


// encapsulates custom actions
// for rows
extension TodosTableViewController {

    // iOS 10 and below
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteRowFromDatabase(with: self.tasks[indexPath.row])
            self.tasks.remove(at: indexPath.row)
            tableView.isEditing = false
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        
        
        let markCompletedAction = UITableViewRowAction(style: .normal, title: "Completed") { (action, indexPath) in
            if self.markTaskAsDoneInDatabase(with: self.tasks[indexPath.row]) {
                self.tasks[indexPath.row].isDone = true
                tableView.isEditing = false
                tableView.reloadData()
            }
        }
        markCompletedAction.backgroundColor = .green
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.currentlySelectedTask = self.tasks[indexPath.row]
            self.tasks.remove(at: indexPath.row)
            self.performSegue(withIdentifier: "DetailedTaskScreenSegue", sender: self)
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
            self.deleteRowFromDatabase(with: self.tasks[indexPath.row])
            self.tasks.remove(at: indexPath.row)
            tableView.isEditing = false
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        
        let markCompletedAction = UIContextualAction(style: .normal, title: "Completed") { (action, view, handler) in
            if self.markTaskAsDoneInDatabase(with: self.tasks[indexPath.row]) {
                self.tasks[indexPath.row].isDone = true
                tableView.isEditing = false
                tableView.reloadData()
            }
        }
        markCompletedAction.backgroundColor = .green
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            self.currentlySelectedTask = self.tasks[indexPath.row]
            self.tasks.remove(at: indexPath.row)
            self.performSegue(withIdentifier: "DetailedTaskScreenSegue", sender: self)
        }
        editAction.backgroundColor = .orange
        
        
        let configuration = UISwipeActionsConfiguration(actions: [markCompletedAction, editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}
