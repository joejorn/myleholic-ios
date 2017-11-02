//
//  ActiveTownManager.swift
//  Myleholic
//
//  Created by Joe on 03.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

protocol TownFinder {
    func getDefaultTown() -> CLPlacemark?
    func getCurrentTown() -> CLPlacemark?
    func getActiveTown(_ date:Date) -> CLPlacemark?
}

class ActiveTownFinder {
    
    fileprivate var realm : Realm!
    
    init() {
		realm = try! Realm()
    }
}

extension ActiveTownFinder: TownFinder {
    
    func getDefaultTown() -> CLPlacemark? {
		let defaults = PreferenceManager.service.getState()
		return defaults.homeplace
    }
    
    func getCurrentTown() -> CLPlacemark? {
        return self.getActiveTown() // or get place of active location
    }
    
    func getActiveTown(_ date:Date = Date()) -> CLPlacemark? {
		
		// CASE 1:
		// check if the given date refers to an existing time interval
        // --------------------------------------------------------------------
        
        // get return travels later than the given date
		let rtnPredicate = NSPredicate(format:"date >= %@", date as NSDate)
        let prevRtns = realm.objects(Travel.self)
						.filter("returnFlag == true")
						.filter( rtnPredicate )
        
        if (prevRtns.count > 0) {
            // get the first return
            let prevRtn = prevRtns.first!
            let prevOut = realm.object(ofType: Travel.self, forPrimaryKey: prevRtn.id - 1)
            
            // ensure that start date of outbound travel is before the given date
            if prevOut != nil && prevOut!.date < date {
				return PlacemarkParser.reverse( prevOut!.owner.place! )
            }
            
        }
        
        
        
		// CASE 2:
		// check the latest one-way journey
        // ----------------------------------------
		
		let singleOuts = realm.objects(Journey.self).filter("travels.@count < 2")
		let outboundArr = singleOuts.map{ $0.travels.first! }
		let prevOutbounds = outboundArr.filter{ $0.date < date }.sorted{ $0.date < $1.date }
		
		if let prev = prevOutbounds.last {
			return PlacemarkParser.reverse( prev.owner.place! )
		}
		
        
        // default: return default town
        // ---------------------------
        return self.getDefaultTown()
    }
    
}

