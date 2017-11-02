//
//  DistanceUnitEnum.swift
//  Myleholic
//
//  Created by Joe on 26.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation

enum DistanceUnit: Int, CustomStringConvertible {
	
	case km = 0, mile
	
	static var count: Int { return DistanceUnit.mile.hashValue + 1 }
	
	var description: String {
		switch self {
		case .km   : return "km"
		case .mile : return "mile"
		}
	}
	
	var abbreviation: String {
		switch self {
		case .km   : return "km"
		case .mile : return "mi"
		}
	}
	
	var divider: Double {
		switch self {
		case .km 	: return 1000.0
		case .mile	: return 1609.344000614692
		}
	}
	
	static var items: [String] {
		return [0..<self.count].flatMap{$0}.map{ DistanceUnit(rawValue: $0)!.description }
	}
	
}
