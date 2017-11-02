//
//  PlacemarkFormatter.swift
//  Myleholic
//
//  Created by Joe on 12.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation

class PlacemarkFormatter {
	
	class func getTitle(_ pm: CLPlacemark) -> String {
		
		let comparePattern = ["", nil]
		guard comparePattern.contains(where: { $0 == pm.postalCode }) ||
			comparePattern.contains(where: { $0 == pm.thoroughfare }) else {
				return pm.name!
		}
		
		return self.getShortAddress(pm)
	}
	
	// city & country
	class func getShortAddress(_ pm: CLPlacemark) -> String {
		
		var words: [String] = []
		let comparePattern = ["", nil]
		
		let local = pm.locality
		if !comparePattern.contains(where: { $0 == local }) {
			let subLocal = pm.subLocality
			
			if !comparePattern.contains(where: { $0 == subLocal }) {
				words.append("\(local!) \(subLocal!)")
			} else {
				words.append(local!)
			}
		}
		
		let country = pm.country
		if !comparePattern.contains(where: { $0 == country }) {
			words.append( country! )
		}
		
		return words.joined(separator: ", ")
	}
	
	class func getFullAddress(_ pm: CLPlacemark) -> String {
		
		var words: [String] = []
		let comparePattern = ["", nil]
		
		if !comparePattern.contains(where: { $0 == pm.thoroughfare }) {
			
			if (pm.subThoroughfare != nil) {
				words.append(pm.thoroughfare! + " " + pm.subThoroughfare!)
			} else {
				words.append(pm.thoroughfare!)
			}
		}
		
		let subAddress = self.getShortAddress(pm)
		if subAddress != "" {
			words.append(subAddress)
		}
		
		if !comparePattern.contains(where: { $0 == pm.postalCode }) {
			words.append(pm.postalCode!)
		}
		
		return words.joined(separator: ", ")
	}
}
