//
//  PreferenceManager.swift
//  Myleholic
//
//  Created by Joe on 10.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

final class PreferenceManager {
	
	static var service = PreferenceManager()
	static var DEFAULT_KEY: String = "com.myleholic.pref"
	
	var state: AppPreferenceState
	
	private init() {
		let store = UserDefaults.standard
		if let prefData = store.data(forKey: PreferenceManager.DEFAULT_KEY) {
			let dict = NSKeyedUnarchiver.unarchiveObject(with: prefData) as! [String: Any]
			state = AppPreferenceState(
				homeplace: dict["homeplace"] as! CLPlacemark,
				homeStart: dict["homeStart"] as! Date,
				unit: dict["unit"] as! Int
			)
		} else {
			// application default place
			let location = CLLocation(latitude: 37.323, longitude: -122.0527)
			let postalAddress = CNMutablePostalAddress()
			postalAddress.city = "Cupertino"
			postalAddress.country = "United States"
			postalAddress.isoCountryCode = "US"
			let placemark = CLPlacemark(location: location, name: "Cupertino", postalAddress: postalAddress as CNPostalAddress)
			
			state = AppPreferenceState(homeplace: placemark, homeStart: Date(), unit: 0)
			saveState()	// init preference
		}
	}
	
	func getState() -> PreferenceState {
		return state
	}
	
	func applyState(_ newState: PreferenceState) {
		state.homeplace = newState.homeplace
		state.homeStart = newState.homeStart
		state.unit = newState.unit
		saveState()
	}
	
	private func saveState() {
		UserDefaults.standard.set(state.getKeyValues(), forKey: PreferenceManager.DEFAULT_KEY)
	}
}
