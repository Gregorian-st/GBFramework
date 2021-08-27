//
//  User+CoreDataProperties.swift
//  
//
//  Created by Grigory Stolyarov on 26.08.2021.
//
//

import Foundation
import CoreData


public class User: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var login: String
    @NSManaged public var password: String
}
