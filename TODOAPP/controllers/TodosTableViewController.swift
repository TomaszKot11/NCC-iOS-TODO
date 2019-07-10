//
//  TodosTableViewController.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 10/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import UIKit
import CoreData

class TodosTableViewController: UITableViewController {
    
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: extract this to utility class
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            tasks = []
            
            for data in result as! [NSManagedObject] {
                print(data)
            
                var task = Task(
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
        
        //TODO: make images scalled - custom TableViewCell (?)
        if let imageName = task.imageName {
            cell.imageView?.image = UIImage(named: imageName)
        }
      
        return cell
    }
 
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
}
