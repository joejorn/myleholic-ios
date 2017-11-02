//
//  Journey.swift
//  Myleholic
//
//  Created by Joe on 02.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import RealmSwift

class Journey: Object {
    
    @objc dynamic var id = 0  // primary key
    @objc dynamic var place: Placemark?
    let travels = List<Travel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
