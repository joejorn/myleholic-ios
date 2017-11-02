//
//  JourneyIOManager.swift
//  Myleholic
//
//  Created by Joe on 03.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

protocol JourneyDataManager {
    func getJournies(filter query: NSPredicate?) -> Results<Journey>
	
	//    func createJourney(_ values: [String:Any?]) -> Journey?
	//	  func createJourney(_ values: [String:Any?])
	//    func setJourney(_ journey: Journey?, withFormValues values: [String:Any?]?)
	
	func setJourney(_ journey: Journey?, withValues formJourney: JourneyFormObject )
    func removeJourney(_ journey: Journey)
    
}

final class JourneyManager {
    
    static let service = JourneyManager()
    
    fileprivate var realm : Realm!
    
    private init() {
		self.realm = try! Realm()
		
		print("Path to realm file: \(realm.configuration.fileURL!.absoluteString)" )
    }
}

extension JourneyManager:JourneyDataManager {
    
    private func getNextId() -> Int {
        return (self.realm.objects(Journey.self).max(ofProperty: "id") as Int? ?? 10) + 10
    }
    
    func getJournies(filter query: NSPredicate? = nil) -> Results<Journey> {
        var results = self.realm.objects(Journey.self)
        if query != nil {
            results = results.filter(query!)
        }
        
        return results
    }
	
	
	// new version
	func setJourney(_ journey: Journey?, withValues formJourney: JourneyFormObject ) {
		
		if journey != nil {
			updateJourney( journey!, formJourney)
		} else {
			newJourney(formJourney)
		}
	}
	
	private func newJourney(_ formJourney: JourneyFormObject) {
		// a place must be given
		guard 	formJourney.place != nil,
				let pm = PlacemarkParser.parse(formJourney.place!) else {
			return
		}
		
		let baseId = self.getNextId()
		let journey = Journey(value: [baseId, pm])
		var travels = Array<Travel>()
		
		// in- & outbound
		let _travels = formJourney.travels
		if _travels.count > 0 {
			for travel in _travels {
				let offset: Int = travel.returnFlag ? 2 : 1
				let outTravel = Travel(value: [baseId + offset, travel.date ?? Date(), travel.returnFlag])
				travels.append(outTravel)
			}
		}
		
		// realm session
		try! self.realm.write {
			realm.add(journey)
			for travel in travels {
				journey.travels.append(travel)
			}
		}
	}
	
	private func updateJourney(_ journey: Journey, _ formJourney: JourneyFormObject) {
		
		// check: place
		if let place = formJourney.place {
			
			let pm = PlacemarkParser.parse(place)
			let curr = journey.place
			
			if  pm != nil && curr != nil && !(pm!.isEqual(curr!)) {
				try! self.realm.write {
					journey.place = pm!
					self.realm.delete(curr!) // delete the old one
				}
			}
			
		}
		
		let _travels = formJourney.travels
		
		// remove some travels
		let diff = journey.travels.count - _travels.count
		if diff > 0 {
			
			try! self.realm.write {
				
				for _ in 0..<diff {
					let lastTravel = journey.travels.last!
					journey.travels.removeLast()
					self.realm.delete(lastTravel)
				}
				
			}
			
		}
		
		// update, determine new travels
		var newTravels: [Travel] = []
		for travelIndex in 0..<_travels.count {
			
			let _travel = _travels[travelIndex]
			
			if travelIndex < journey.travels.count {
				// update travel
				let travel = journey.travels[travelIndex]
				try! self.realm.write {
					travel.date = _travel.date ?? Date()
					travel.returnFlag = _travel.returnFlag
				}
				
			} else {
				// add new travel
				let nextId: Int = journey.id + travelIndex + 1
				let newTravel = Travel(value: [nextId, _travel.date ?? Date(), _travel.returnFlag])
				newTravels.append(newTravel)
			}
		}
		if newTravels.count > 0 {
			// add all new
			
			try! self.realm.write {
				for travel in newTravels {
					journey.travels.append(travel)
				}
			}
			
		}
		
	}
    
    func removeJourney(_ journey: Journey) {
		
        try! self.realm.write {
            
            journey.travels.forEach({ realm.delete($0) })
			
			if let place = journey.place {
				self.realm.delete(place)
			}
			
            self.realm.delete(journey)
        }
    }
    
}
