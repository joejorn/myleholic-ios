//
//  Travel.swift
//  Myleholic
//
//  Created by Joe on 21.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import RealmSwift

class Travel: Object {
	@objc dynamic var id = 0  // primary key
	@objc dynamic var date: Date = Date()
	@objc dynamic var returnFlag: Bool = false
	
	// inverse relationship
	private let owners = LinkingObjects(fromType: Journey.self, property: "travels")
	var owner: Journey { return self.owners.first! }
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
