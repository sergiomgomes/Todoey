//
//  Item.swift
//  Todoey
//
//  Created by Sergio Gomes on 19/03/18.
//  Copyright © 2018 Sergio Gomes. All rights reserved.
//

import Foundation
class Item : Encodable, Decodable{
    
    var title: String
    var done: Bool
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
