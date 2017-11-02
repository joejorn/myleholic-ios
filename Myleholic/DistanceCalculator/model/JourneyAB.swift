//
//  JourneyAB.swift
//  Myleholic
//
//  Created by Joe on 29.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation

// Simplified type of a journey that facilitate distance map component
struct JourneyAB {
	
	var id: Int	// journey id
	var origin: CLPlacemark
	var destination: CLPlacemark
	var start: Date
	var distance: CLLocationDistance {
		return DistanceCalculator.distanceAB(origin, destination)
	}
	var enabled: Bool = true	// hidden or visible to calculator
	
}
