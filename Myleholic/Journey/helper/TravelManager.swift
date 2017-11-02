//
//  TravelManager.swift
//  Myleholic
//
//  Created by Joe on 03.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import RealmSwift

protocol TravelDataManager {
    func getTravels(from fromDate: Date?, to toDate: Date?)
    
    func getOneWayTravels(from fromDate: Date?, to toDate: Date?)
    
    func getReturnTravels(from fromDate: Date?, to toDate: Date?)
}

final class TravelManager {
	
	static let service = TravelManager()
    private var realm: Realm!
    
    private init() {
//        self.realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TestInMemoryRealm"))
		self.realm = try! Realm()
    }
	
	func getTravels() -> Results<Travel> {
		return self.realm.objects(Travel.self)
	}
    
    func getOutboundTravels() -> Results<Travel> {
        
        return self.realm.objects(Travel.self)
                    .filter("returnFlag == \(NSNumber(booleanLiteral: false))")
//                    .sorted(byKeyPath: "date", ascending: false)
    }
    
}
