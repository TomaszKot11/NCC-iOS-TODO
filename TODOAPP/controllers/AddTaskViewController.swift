//
//  AddTaskViewController.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 10/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddTaskViewController: UIViewController {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    private var savedTask: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addTaskButtonClicked(_ sender: Any) {
        savedTask = Task(
            title: titleTextView.text ?? "No title provided",
            description: descriptionTextView.text ?? "No description provided",
            date: dateTextField.text ?? "No date provided",
            isDone: isDoneSwitch.isOn,
            uuid: UUID().uuidString
        )
        
        //TODO: extract this to utility class
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
    
        newTask.setValue(savedTask!.title, forKey: "title")
        newTask.setValue(savedTask!.description, forKey: "details")
        newTask.setValue(savedTask!.date, forKey: "date")
        newTask.setValue(savedTask!.isDone, forKey: "isDone")
        newTask.setValue(savedTask!.uuid, forKey: "uuid")
        
        //TODO: do we need this here?
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateTaskSegue" {
            if let destinationViewController = segue.destination as? TodosTableViewController, let savedTaskUnwrapped = self.savedTask {
                destinationViewController.tasks.append(savedTaskUnwrapped)
                destinationViewController.tableView.reloadData()
            }
        }
    }
    
    
}
