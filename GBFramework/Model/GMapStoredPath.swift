//
//  GMapStoredPath.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 24.08.2021.
//

import CoreData

public class GMapStoredPath: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GMapStoredPath> {
        
        return NSFetchRequest<GMapStoredPath>(entityName: "GMapStoredPath")
    }
    
    @NSManaged public var id: String
    @NSManaged public var encodedPath: String
}
