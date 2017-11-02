//
//  FilterInterval.swift
//  Myleholic
//
//  Created by Joe on 01.11.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation

enum FilterInterval: Int, CustomStringConvertible {
	
	case any = 0
	case allUpcomings = 1
	case untilNow = 2
	case currentYear = 3
	case lastYear = 4
	case pastYears = 5
	
	static var count:Int { return FilterInterval.pastYears.hashValue + 1 }
	
	static var catalog:[String] {
		return [0..<self.count].flatMap{$0}.map{ FilterInterval(rawValue: $0)!.description }
	}
	
	var interval: DateInterval {
		
		var startDate, endDate: Date!
		
		switch self {
		case .allUpcomings:
			startDate = Date()
			endDate = Date.distantFuture
			break
			
		case .untilNow:
			startDate = Date.distantPast
			endDate = Date()
			break
			
		case .currentYear, .lastYear:
			let calendar = Calendar.current	// calendar object
			let currentYear = calendar.component(Calendar.Component.year, from: Date())
			
			var customDate = DateComponents()
			
			// begin of year
			customDate.year = (self == .currentYear) ? currentYear : currentYear - 1
			customDate.month = 1
			customDate.day = 1
			let firstDate = calendar.date(from: customDate)	// 1 JAN
			startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: firstDate!)
			
			// end of year
			customDate.month = 12
			customDate.day = 31
			let lastDate = calendar.date(from: customDate)	// 31 DEC
			endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDate!)
			break
			
		case .pastYears:
			startDate = Date.distantPast	// past centuries
			
			let calendar = Calendar.current	// calendar object
			let currentYear = calendar.component(Calendar.Component.year, from: Date())
			
			// end of previous year
			var customDate = DateComponents()
			customDate.year = currentYear - 1
			customDate.month = 12
			customDate.day = 31
			let lastDate = calendar.date(from: customDate)	// 31 DEC
			endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDate!)
			break
			
		default: // any
			startDate = Date.distantPast
			endDate = Date.distantFuture
		}
		
		return DateInterval(start: startDate, end: endDate)
	}
	
	var description: String {
		switch self {
		case .any			: return "Any"
		case .allUpcomings	: return "Upcomings"
		case .untilNow  	: return "Until now"
		case .currentYear 	: return "This year"
		case .lastYear 		: return "Last year"
		case .pastYears 	: return "Past years"
		}
	}
}
