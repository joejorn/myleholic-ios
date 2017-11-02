//
//  JourneyFormHelper.swift
//  Myleholic
//
//  Created by Joe on 04.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import MapKit

// Simplified Journey Object
struct JourneyFormObject {
	var place: CLPlacemark?
	var travels:Array<TravelFormObject>
}

// Simplified Travel Object
struct TravelFormObject {
	var date: Date? = Date()
	var returnFlag: Bool = false
}

final class JourneyFormHelper {
	
	class func extractFormValues(_ jn: Journey?) -> [String: Any?]? {
		
		guard let journey = jn else { return nil }
		
		var dict: [String:Any?] = [:]
		
		// row - destination
		if 	journey.place != nil,
			let clPlacemark = PlacemarkParser.reverse(journey.place!) {
			dict[JourneyFormMeta.destination.propertyName] = MKPlacemark(placemark: clPlacemark)
		}
		
		// row - has return
		let hasRtn = journey.travels.count > 1
		dict[JourneyFormMeta.hasReturn.propertyName] = hasRtn
		
		// section - outbound
		if let outTravel = journey.travels.first {
			dict[JourneyFormMeta.startDate.propertyName] = outTravel.date
			dict[JourneyFormMeta.startTime.propertyName] = outTravel.date
		}
		
		// section - return
		if 	hasRtn,
			let rtnTravel = journey.travels.last {
			dict[JourneyFormMeta.returnDate.propertyName] = rtnTravel.date
			dict[JourneyFormMeta.returnTime.propertyName] = rtnTravel.date
		}
		
		return dict
	}
	
	class func parseFormValues(_ formValues: [String: Any?]) -> JourneyFormObject {

		let dest = JourneyFormMeta.destination.propertyName
		let place = formValues[dest] as? CLPlacemark
		
		var travels: Array<TravelFormObject> = []
		
		// outbound
		let startDate = formValues[JourneyFormMeta.startDate.propertyName] as! Date
		let startTime = formValues[JourneyFormMeta.startTime.propertyName] as! Date
		if let newDatetime = setTimeFromDate(startDate, withTimeFromDate: startTime) {
			travels.append(TravelFormObject(date: newDatetime, returnFlag: false))
		}
		
		// return
		let rtnBool = formValues[JourneyFormMeta.hasReturn.propertyName] as! Bool
		if rtnBool {
			let rtnDate = formValues[JourneyFormMeta.returnDate.propertyName] as! Date
			let rtnTime = formValues[JourneyFormMeta.returnTime.propertyName] as! Date
			
			if let newDatetime = setTimeFromDate(rtnDate, withTimeFromDate: rtnTime) {
				travels.append( TravelFormObject(date: newDatetime, returnFlag: true) )
			}
		}
		
		return JourneyFormObject(place: place, travels: travels)
	}
	
	
	private class func setTimeFromDate(_ baseDate: Date, withTimeFromDate nextDate: Date) -> Date? {
		let calendar = Calendar.current
		let dateComponents = calendar.dateComponents([.hour, .minute], from: nextDate)
		
		return calendar.date(bySettingHour: dateComponents.hour!, minute: dateComponents.minute!, second: 0, of: baseDate)
	}
	

	class func validateFormObject(_ o: JourneyFormObject) -> Bool {
		
		// TODO:
		// check following two cases
		
		// case 1
		// the journey begins in between of an existing time-interval
		// but ends after that journey
		
		// case 2
		// the journey begins before another journey
		// but ends in between of that journey
		
		return false
	}
}
