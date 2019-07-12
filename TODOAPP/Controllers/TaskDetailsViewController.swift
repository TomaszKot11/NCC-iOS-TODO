//
//  AddTaskViewController.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 10/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import Foundation
import UIKit

class TaskDetailsViewController: UIViewController {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var isDoneSwitch: UISwitch!
    @IBOutlet weak var viewButton: UIButton!
    
    var currentTask: Task?
    // could be a struct
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
        
        if isEditingTask {
            DatabaseService.editTask(uuid: uuid, updatedTask: currentTask!)
        } else {
            DatabaseService.saveNewTaskToDatabase(taskWithValues: currentTask!)
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
