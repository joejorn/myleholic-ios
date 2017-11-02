//
//  DistanceCalculator.swift
//  Myleholic
//
//  Created by Joe on 26.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation

final class DistanceCalculator {
	
	static func convert(_ meters: Double, to unit: DistanceUnit) -> Double {
		return meters/unit.divider
	}
	
	static func distanceAB(_ placemarkA: CLPlacemark, _ placemarkB: CLPlacemark) -> CLLocationDistance {
		guard 	let locA = placemarkA.location,
				let locB = placemarkB.location
			else { return 0.0 }
		
		return locA.distance(from: locB)
	}
	
	// Calculate geographical distance between two placemarks according to a given unit
	static func geoDistance(from origin: CLPlacemark, to destination: CLPlacemark, unit: DistanceUnit = DistanceUnit.km) -> CLLocationDistance {
		guard 	let _origin = origin.location,
			let _destination = destination.location
			else { return 0.0 }
		return geoDistance(from: _origin, to: _destination, unit: unit)
	}
	
	// Calculate geographical distance between two locations according to a given unit
	static func geoDistance(from origin: CLLocation, to destination: CLLocation, unit: DistanceUnit = DistanceUnit.km) -> CLLocationDistance {
		return (origin.distance(from: destination)) / unit.divider
	}
	
}
