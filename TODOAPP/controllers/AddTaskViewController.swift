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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addTaskButtonClicked(_ sender: Any) {
         var task = Task(
            title: titleTextView.text ?? "No title provided",
            description: descriptionTextView.text ?? "No description provided",
            date: dateTextField.text ?? "No date provided",
            imageName: "Apple"
            )
        
        //TODO: extract this to utility class
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        
        newTask.setValue(task.title, forKey: "title")
        newTask.setValue(task.description, forKey: "details")
        newTask.setValue(task.date, forKey: "date")
    }
}
