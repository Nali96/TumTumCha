//
//  SaveData.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 22/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation
import CoreData
import UIKit


protocol DataManaging {   //protocol used by all the managers to store,retrieve,delete and modify data
    func saveData(idLevel: String, idWorld: String, accuracy: Int) //Function to store the data
    func loadData(idWorld: String) -> NSArray // Function to retrieve all the data
    func deleteData(idLevel: String, idWorld: String) // Function to delete a certain data
    func deleteAllData()
    func modifyData(idLevel: String, idWorld: String, newAccuracy: Int) // Function to modify a certain data
    func findOneLevel(idLevel: String, idWorld: String) -> NSArray
}


class SaveDataManager: DataManaging { // manager that is used to interface the user with the outside
   
    
    private var handler: DataManaging?
    
    init() {
        handler = CoreDataManager()  // Use this variables to use all the function from outside
    }
    
    
    func saveData(idLevel: String, idWorld: String, accuracy: Int) {
        handler?.saveData(idLevel: idLevel, idWorld: idWorld, accuracy: accuracy)
    }
    
    func loadData(idWorld: String) -> NSArray {
        return (handler?.loadData(idWorld: idWorld))!
    }
    
    func deleteData(idLevel: String, idWorld: String) {
        handler?.deleteData(idLevel: idLevel, idWorld: idWorld)
    }
    
    func deleteAllData() {
        handler?.deleteAllData()
    }
    
    func modifyData(idLevel: String, idWorld: String, newAccuracy: Int) {
        handler?.modifyData(idLevel: idLevel, idWorld: idWorld, newAccuracy: newAccuracy)
    }
    func findOneLevel(idLevel: String, idWorld: String) -> NSArray {
        return (handler?.findOneLevel(idLevel: idLevel, idWorld: idWorld))!
    }
}


class CoreDataManager: DataManaging {//Manager for coreData structure
    
    
   private var context: NSManagedObjectContext
    
    init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    
    func saveData(idLevel: String, idWorld: String, accuracy: Int) {
        let entity = NSEntityDescription.entity(forEntityName: "Accuracy", in: self.context)!
        let newAccuracyData = Accuracy(entity: entity, insertInto: self.context)
        newAccuracyData.idLevel = idLevel
        newAccuracyData.idWorld = idWorld
        newAccuracyData.accuracy = Int16(accuracy)
        self.saveContex()
    }
    
    
    func findOneLevel(idLevel: String, idWorld: String)-> NSArray {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accuracy")
        let predicate = NSPredicate(format: "idLevel == %@ AND idWorld == %@", idLevel,idWorld)
        return executeQuery(predicate: predicate, request: request, sortDescriptor: nil)
    }
    
    
    private func saveContex() { //Function to store permanently data on core data
    
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    func loadData(idWorld: String) -> NSArray {
        var data: NSArray
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accuracy")
        let predicate = NSPredicate(format: "idWorld == %@",idWorld)
        let sortDescriptors = [NSSortDescriptor(key: "idLevel", ascending: true)]
        data = executeQuery(predicate: predicate, request: request, sortDescriptor: sortDescriptors)
        return data
    }
    
    func deleteData(idLevel: String, idWorld: String) {
        let predicate = NSPredicate(format: "idLevel == %@ AND idWorld == %@", idLevel,idWorld)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accuracy")
        let data = executeQuery(predicate: predicate, request: request, sortDescriptor: nil)
        for item in data {
            self.context.delete(item as! Accuracy)
        }
        self.saveContex()
    }
    
    func deleteAllData() {
        let predicate = NSPredicate(value: true)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accuracy")
        let data = executeQuery(predicate: predicate, request: request, sortDescriptor: nil)
        for item in data {
            self.context.delete(item as! Accuracy)
        }
        self.saveContex()
    }
    
    func modifyData(idLevel: String, idWorld: String, newAccuracy: Int) {
        let predicate = NSPredicate(format: "idLevel == %@ AND idWorld == %@", idLevel,idWorld)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accuracy")
        let data = executeQuery(predicate: predicate, request: request, sortDescriptor: nil)
        if data.count != 0 {
            let newdata = data.firstObject as! Accuracy
            newdata.accuracy = Int16(newAccuracy)
            self.saveContex()
        }
        else {
            print("Don't exist")
        }
    }
    
    private func executeQuery(predicate: NSPredicate?, request:  NSFetchRequest<NSFetchRequestResult>, sortDescriptor: [NSSortDescriptor]?) -> NSArray { // Function to execute all the querys related to the Accuracy entity
    
        var data = NSArray()
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = sortDescriptor //sort descriptor to have an ordered collection of data
        do {
            data = try self.context.fetch(request) as NSArray
        } catch let error {
            print(error)
        }
        return data
    }
    
}

class UserDefaultManager: DataManaging { //These function will be updated

    private var userDefaults = UserDefaults.standard
    
    func loadData(idWorld: String) -> NSArray {
        var data: NSArray = NSArray()
        print("Working On")
        return data
    }
    
    func deleteData(idLevel: String, idWorld: String) {
        print("Working On")
    }
    
    func deleteAllData() {
        print("Working On")
    }
    
    func modifyData(idLevel: String, idWorld: String, newAccuracy: Int) {
        print("Working On")
    }
    
    func saveData(idLevel: String, idWorld: String, accuracy: Int) {
        print("Working On")
    }
    
    func findOneLevel(idLevel: String, idWorld: String)-> NSArray {
        var data: NSArray = NSArray()
        print("Working On")
        return data
    }
}
