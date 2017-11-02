//
//  SettingsFormMeta.swift
//  Airholic
//
//  Created by Joe on 28.08.17.
//
//

import Foundation

enum PreferenceMeta: Int, CustomStringConvertible {
    
    case home = 0
    case homeSince = 1
    case unit = 2
    case distance = 3
    
    static var count: Int { return PreferenceMeta.distance.hashValue + 1 }
    
    var description: String {
        switch self {
        case .home: return "Hometown"
        case .homeSince: return "Since"
        case .unit  : return "Unit"
        case .distance : return "Distance including Return"
        }
    }
    
    var propertyName: String {
        let prefix = "mh_pref_"
        var attr = ""
        
        switch self {
        case .home: attr = "home"
        case .homeSince: attr = "since"
        case .unit  : attr = "unit"
        case .distance : attr = "distance"
        }
        
        return prefix + attr
    }
	
	/*
    var propertyType: AnyClass {
        var className = "String"
        switch self {
        case .home: className = "MKPlacemark"
        case .homeSince: className = "Date"
        case .unit  : className = "String"
        case .distance : className = "Bool"
        }
        
        return NSClassFromString(className)!
    }
	*/
    
    var defaultValue: Any? {
        switch self {
        case .home: return nil
        case .homeSince: return Date()
        case .unit  : return DistanceUnit.km
        case .distance : return true
        }
        
    }
}
