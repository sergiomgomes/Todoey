//
//  Item.swift
//  Todoey
//
//  Created by Sergio Gomes on 23/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    
    @objc dynamic var done: Bool = false
    
    @objc dynamic var dateCreated: Date = Date()
    
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
