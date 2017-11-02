//
//  Placemark.swift
//  Myleholic
//
//  Created by Joe on 30.08.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class Placemark: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var countryCode: String = ""
    @objc dynamic var country: String = ""
    @objc dynamic var postalCode: String? = nil
    @objc dynamic var locality: String? = nil
    @objc dynamic var subLocality: String? = nil
    @objc dynamic var thoroughfare: String? = nil
    @objc dynamic var subThoroughfare: String? = nil
    
    // location
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    // read-only
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
	
	// Readable address by concatenating city and country
	var shortAddress: String {
		var words: [String] = []
		let comparePattern = ["", nil]

		let local = self.locality
		if !comparePattern.contains(where: { $0 == local }) {
			let subLocal = self.subLocality
			
			if !comparePattern.contains(where: { $0 == subLocal }) {
				words.append("\(local!) \(subLocal!)")
			} else {
				words.append(local!)
			}
		}
		
		let country = self.country
		if !comparePattern.contains(where: { $0 == country }) {
			words.append( country )
		}
		
		return words.joined(separator: ", ")
	}
	
	// Equality check by name and coordinates
	override func isEqual(_ object: Any?) -> Bool {
		
		let pm1 = (self)
		guard let pm2 = object as? Placemark else { return false }
		
		guard (pm1.name == pm2.name) else { return false }
		
		let coordA = pm1.location.coordinate
		let coordB = pm2.location.coordinate
		
		guard 	(coordA.latitude == coordB.latitude),
				(coordA.longitude == coordB.longitude)
			else { return false }
		
		return true
	}
}
