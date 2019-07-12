//
//  DatabaseService.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 12/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// serives performing database operations needed across
// the project
public class DatabaseService: NSObject {
    private static var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private static var context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
    
    public static func saveNewTaskToDatabase( taskWithValues: Task) {
        let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        
        setTaskValues(savingTask: newTask, valueSourceTask: taskWithValues)
        
        //TODO: do we need this here?
        saveWholeContext()
    }
    
    public static func editTask(uuid: String, updatedTask: Task) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", uuid)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let firstResult = results.first as? NSManagedObject {
                setTaskValues(savingTask: firstResult, valueSourceTask: updatedTask)
            }
            
            saveWholeContext()
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    public static func getAllTasks(request: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext) -> [Task] {
        var tasks = [Task]()
    
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)

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
    
        return tasks
    }
    
    public static func markTaskAsDoneInDatabase(with task: Task) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", task.uuid)
        do {
            let results = try context.fetch(fetchRequest)
            if let firstResult = results.first as? NSManagedObject {
                firstResult.setValue(true, forKey: "isDone")
            }
            
            //TODO: do we need this here?
            return saveWholeContext()
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
    public static func deleteRowFromDatabase(with task: Task) -> Bool {
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
    
    // helper functions
    private static func setTaskValues(savingTask: NSManagedObject, valueSourceTask: Task) {
        savingTask.setValue(valueSourceTask.title, forKey: "title")
        savingTask.setValue(valueSourceTask.description, forKey: "details")
        savingTask.setValue(valueSourceTask.date, forKey: "date")
        savingTask.setValue(valueSourceTask.isDone, forKey: "isDone")
        savingTask.setValue(valueSourceTask.uuid, forKey: "uuid")
    }
    
    private static func saveWholeContext() -> Bool {
        //TODO: do we need this here?
        do {
            try context.save()
            return true
        } catch let error as NSError {
            print(error)
            return false
        }
    }
}
