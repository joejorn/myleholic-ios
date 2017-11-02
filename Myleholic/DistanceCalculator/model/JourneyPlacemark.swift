//
//  JourneyPlacemark.swift
//  Myleholic
//
//  Created by Joe on 29.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation

typealias JourneyDateInterval = RawDateInterval

struct RawDateInterval {
	var start: Date
	var end: Date?
}

// Flat level of a journey
struct JourneyPlacemark {
	var id: Int
	var placemark: CLPlacemark
	var start: Date
	var end: Date?
	var intervals = [RawDateInterval]()
	var enabled: Bool = true	// active annotation on the map
	
	// Creates and initializes an object using the specified journey.
	init(_ journey: Journey) {
		id = journey.id
		placemark = PlacemarkParser.reverse(journey.place!)!
		
		let travels = journey.travels
		start = travels.first!.date
		end = travels.count > 1 ? travels.last!.date : nil
	}
	
	// Creates and initializes an object from another placemark object with specified date.
	init(placemark pm: CLPlacemark, start _start: Date, end _end: Date? = nil) {
		id = 0
		placemark = pm
		start = _start
		end = _end
	}
	
	init(placemark pm: CLPlacemark, intervals dateInterval: [RawDateInterval] = []) {
		id = 0
		placemark = pm
		intervals = dateInterval
		
		// remove later
		start = Date()
	}
}
