//
//  PreferenceState.swift
//  Myleholic
//
//  Created by Joe on 10.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation

protocol PreferenceState {
	var homeplace: CLPlacemark { get set }
	var homeStart: Date { get set }
	var unit: Int { get set }
}

protocol ConvertibleState {
	func getKeyValues() -> Data
}

struct AppPreferenceState: PreferenceState, ConvertibleState {
	
	var homeplace: CLPlacemark
	var homeStart: Date
	var unit: Int
	
	func getKeyValues() -> Data {
		let values: [String: Any] = [
			"homeplace": homeplace,
			"homeStart": homeStart,
			"unit": unit
		]
		return NSKeyedArchiver.archivedData(withRootObject: values)
	}
}
