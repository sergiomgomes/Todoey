//
//  Category.swift
//  Todoey
//
//  Created by Sergio Gomes on 23/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    
    let items = List<Item>()
}
