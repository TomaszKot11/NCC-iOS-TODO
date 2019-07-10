//
//  TodosTableViewController.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 10/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import UIKit

class TodosTableViewController: UITableViewController {
    
    var tasks = [
        Task(id: 0, description: "Wash the dishes", date: "10-07-2019 13:00", imageName: "Apple"),
        Task(id: 1, description: "Take out the trash", date: "11-07-2019 6:00", imageName: "Apricot"),
        Task(id: 2, description: "Walk the dog", date: "12-07-2019 11:00", imageName: "Apple"),
        Task(id: 3, description: "Learn programming language", date: "13-97-2019 12:00")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        cell.textLabel?.text = "Id: \(task.id), description: \(task.description)"
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
