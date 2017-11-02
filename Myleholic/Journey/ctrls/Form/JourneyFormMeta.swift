//
//  JourneyFormMeta.swift
//  Airholic
//
//  Created by Joe on 28.08.17.
//
//

import Foundation

enum JourneyFormMeta: Int, CustomStringConvertible {
    
    case destination = 0
    case hasReturn = 1
    case startDate = 2
	case startTime = 3
    case returnDate = 4
	case returnTime = 5
	
    static var count: Int { return JourneyFormMeta.returnTime.hashValue + 1 }
    
    var description: String {
        switch self {
        case .destination: return "Destination"
        case .hasReturn: return "Turnaround"
        case .startDate, .returnDate  : return "Date"
		case .startTime, .returnTime : return "Time"
        }
    }
    
    var propertyName: String {
        switch self {
        case .destination: return "place"
        case .hasReturn: return "isTurnaround"
        case .startDate  : return "out_start"
		case .startTime  : return "out_time"
        case .returnDate: return "in_start"
		case .returnTime: return "in_time"
        }
    }
    
}
