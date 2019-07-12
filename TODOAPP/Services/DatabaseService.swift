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
    
    public static func saveNewTaskToDatabase( taskWithValues: Task?) {
        
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        
        newTask.setValue(taskWithValues!.title, forKey: "title")
        newTask.setValue(taskWithValues!.description, forKey: "details")
        newTask.setValue(taskWithValues!.date, forKey: "date")
        newTask.setValue(taskWithValues!.isDone, forKey: "isDone")
        newTask.setValue(taskWithValues!.uuid, forKey: "uuid")
        
        //TODO: do we need this here?
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    public static func editTask(uuid: String, updatedTask: Task?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        //TODO: avoid force unwrapping
        fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", uuid)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let firstResult = results.first as? NSManagedObject {
                firstResult.setValue(updatedTask!.title, forKey: "title")
                firstResult.setValue(updatedTask!.description, forKey: "details")
                firstResult.setValue(updatedTask!.date, forKey: "date")
                firstResult.setValue(updatedTask!.isDone, forKey: "isDone")
                firstResult.setValue(updatedTask!.uuid, forKey: "uuid")
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
    
//    public static
    
    public static func deleteRowFromDatabase(with task: Task) -> Bool {
        
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

}
