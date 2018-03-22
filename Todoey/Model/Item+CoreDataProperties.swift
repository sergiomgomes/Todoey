//
//  Item+CoreDataProperties.swift
//  Todoey
//
//  Created by Sergio Gomes on 22/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var done: Bool
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}
