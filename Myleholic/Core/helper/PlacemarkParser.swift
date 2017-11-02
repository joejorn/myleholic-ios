//
//  PlacemarkParser.swift
//  Myleholic
//
//  Created by Joe on 08.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import Intents
import Contacts.CNPostalAddress
import CoreLocation

final class PlacemarkParser {
	
	/// transform a built-in placemark object to a custom placemark object
	class func parse(_ pm: CLPlacemark) -> Placemark? {
		
		guard let loc = pm.location else { return nil }
		
		let _pm = Placemark()
		_pm.name = pm.name!
		_pm.country = pm.country!
		_pm.countryCode = pm.isoCountryCode!
		_pm.postalCode = pm.postalCode
		_pm.locality = pm.locality
		_pm.subLocality = pm.subLocality
		_pm.thoroughfare = pm.thoroughfare
		_pm.subThoroughfare = pm.subThoroughfare
		
		let coord = loc.coordinate
		_pm.latitude = coord.latitude
		_pm.longitude = coord.longitude
		
		return _pm
	}
	
	/// inverse transformation of a custom placemark object to built-in placemark object
	class func reverse(_ pm: Placemark) -> CLPlacemark? {
		let loc = CLLocation(latitude: pm.latitude, longitude: pm.longitude)
		let postalAddr = self.postalAddress(pm)
		
		return CLPlacemark(location: loc, name: pm.name, postalAddress: postalAddr)
	}
	
	/// transformation of a custom placemark object to a built-in address object
	class func postalAddress(_ pm: Placemark) -> CNPostalAddress {
		
		let keys: [(attrKey: String, addrKey: String)] = [
			("thoroughfare", CNPostalAddressStreetKey),
			("locality", CNPostalAddressCityKey),
			("subLocality", CNPostalAddressSubLocalityKey),
			("postalCode", CNPostalAddressPostalCodeKey),
			("country", CNPostalAddressCountryKey),
			("countryCode", CNPostalAddressISOCountryCodeKey),
			]
		
		let addr = CNPostalAddress()
		keys.forEach({
			let key = $0
			var val = pm.value(forKey: key.attrKey)
			if (val != nil) {
				// Concatenate street name and house number
				if (key.addrKey == CNPostalAddressStreetKey),
					let subVal =  pm.value(forKey: "subThoroughfare") {
					val = (val as! String).appending(" " + (subVal as! String))
				}
				addr.setValue(val!, forKey: key.addrKey)
			}
		})
		return addr
	}
}
