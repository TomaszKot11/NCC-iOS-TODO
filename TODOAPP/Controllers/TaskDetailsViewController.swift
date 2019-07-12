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

class TaskDetailsViewController: UIViewController {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var isDoneSwitch: UISwitch!
    @IBOutlet weak var viewButton: UIButton!
    
    var currentTask: Task?
    // could bne a struct
    var initialTitleValue: String?
    var initialDescriptionValue: String?
    var initialDateValue: String?
    var initialIsDoneValue: Bool?
    var isEditingTask = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialState()
    }
    
    
    private func setInitialState() {
        if let titleValue = initialTitleValue, let descriptionValue = initialDescriptionValue, let dateValue = initialDateValue, let isDoneValue = initialIsDoneValue {
            
            titleTextView.text = titleValue
            descriptionTextView.text = descriptionValue
            dateTextField.text = dateValue
            isDoneSwitch.isOn = isDoneValue
            viewButton.setTitle("Edit", for: .normal)
            isEditingTask = true
        }
    }
    
    @IBAction func addTaskButtonClicked(_ sender: Any) {
        let uuid = currentTask?.uuid ?? UUID().uuidString
        currentTask = Task(
            title: titleTextView.text ?? "No title provided",
            description: descriptionTextView.text ?? "No description provided",
            date: dateTextField.text ?? "No date provided",
            isDone: isDoneSwitch.isOn,
            uuid: uuid
        )
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //TODO: extract this to utility(service) class
        if isEditingTask {
            editTaskInTheDatabase(context: context, uuid: uuid)
        } else {
            saveNewTaskToDatabase(context: context)
        }
    }
    
    private func editTaskInTheDatabase(context: NSManagedObjectContext, uuid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        //TODO: avoid force unwrapping
        fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", uuid)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let firstResult = results.first as? NSManagedObject {
                firstResult.setValue(currentTask!.title, forKey: "title")
                firstResult.setValue(currentTask!.description, forKey: "details")
                firstResult.setValue(currentTask!.date, forKey: "date")
                firstResult.setValue(currentTask!.isDone, forKey: "isDone")
                firstResult.setValue(currentTask!.uuid, forKey: "uuid")
            }
            
            //TODO: do we need this here?
            do {
                try context.save()
                //                self.tableView.reloadData()
            } catch let error as NSError {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    private func saveNewTaskToDatabase(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        
        newTask.setValue(currentTask!.title, forKey: "title")
        newTask.setValue(currentTask!.description, forKey: "details")
        newTask.setValue(currentTask!.date, forKey: "date")
        newTask.setValue(currentTask!.isDone, forKey: "isDone")
        newTask.setValue(currentTask!.uuid, forKey: "uuid")
        
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
            if let destinationViewController = segue.destination as? TodosTableViewController, let savedTaskUnwrapped = self.currentTask {
                destinationViewController.tasks.append(savedTaskUnwrapped)
                destinationViewController.tableView.reloadData()
            }
        }
    }
    
    
}
