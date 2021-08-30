//
//  CoreDataService.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit
import CoreData

final class CoreDataService {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func savePath(stringPath: String?) {
        
        guard let encodedPath = stringPath
        else { return }
        
        // Delete all rows
        let fetchRequest: NSFetchRequest<GMapStoredPath> = GMapStoredPath.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id CONTAINS %@", "lastValue")
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        } catch _ {
            print("Error deleting paths!")
        }
        
        // Add the row with last path
        let storedPath = GMapStoredPath(context: context)
        storedPath.id = "lastValue"
        storedPath.encodedPath = encodedPath
        do {
            try context.save()
        }
        catch {
            print("Error saving path!")
        }
    }
    
    func loadPath() -> String? {
        
        let fetchRequest: NSFetchRequest<GMapStoredPath> = GMapStoredPath.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id CONTAINS %@", "lastValue")
        do {
            let objects = try context.fetch(fetchRequest)
            if let encodedPath = objects.first?.encodedPath {
                return encodedPath
            }
        } catch _ {
            print("Error deleting paths!")
        }
        return nil
    }
    
    func authLogin(login: String, password: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login MATCHES %@", login)
        do {
            if let user = try context.fetch(fetchRequest).first {
                if user.login == login && user.password == password {
                    return true
                }
            }
        } catch _ {
            print("Error reading user!")
        }
        return false
    }
    
    func authSignUp(login: String, password: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login MATCHES %@", login)
        do {
            if let user = try context.fetch(fetchRequest).first {
                user.password = password
                try context.save()
                return true
            } else {
                let user = User(context: context)
                user.login = login
                user.password = password
                try context.save()
                return true
            }
        } catch _ {
            print("Error reading user!")
        }
        return false
    }
}
