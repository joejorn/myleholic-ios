//
//  SettingsFormController.swift
//  Airholic
//
//  Created by Joe on 27.08.17.
//
//

import Foundation
import Eureka
import MapKit

class PreferenceFormController: FormViewController {
	
	var prefManager: PreferenceManager = PreferenceManager.service
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let defaults = UserDefaults.standard
		var state = prefManager.getState()
        
        form
            +++ Section("initial hometown")
            <<< LocationRow() {
                    let prop = PreferenceMeta(rawValue: 0)!
                    $0.title = prop.description
					$0.value = MKPlacemark(placemark: state.homeplace) // state.homeplace
				/*
                    if let propValue = defaults.value(forKey: prop.propertyName) as? Data {
                        $0.value = NSKeyedUnarchiver.unarchiveObject(with: propValue) as? MKPlacemark
                    }
				*/
                }.onChange({ (row) in
					state.homeplace = row.value!
					self.prefManager.applyState(state)
					/*
                    let prop = PreferenceMeta(rawValue: 0)!
                    let rowData = NSKeyedArchiver.archivedData(withRootObject: row.value as Any)
                    defaults.set(rowData, forKey: (prop.propertyName))
					*/
                })
            <<< DateInlineRow(){
                    let prop = PreferenceMeta(rawValue: 1)!
                    $0.title = prop.description
					$0.value = state.homeStart
//                    $0.value = (defaults.object(forKey: prop.propertyName) ?? prop.defaultValue) as? Date
                }.onChange({ (row) in
					state.homeStart = row.value!
					self.prefManager.applyState(state)
//                    let prop = PreferenceMeta(rawValue: 1)!
//                    defaults.set(row.value, forKey: prop.propertyName)
                })
            
            +++ Section("map")
            <<< PickerInlineRow<String>("Unit") {
                    let prop = PreferenceMeta(rawValue: 2)!
                    $0.title = prop.description
                    $0.options = DistanceUnit.items
					let selectionIndex = state.unit
//					let selectionIndex = defaults.value(forKey: prop.propertyName) as? Int ?? (prop.defaultValue as! DistanceUnit).hashValue
                    $0.value = $0.options[selectionIndex]
                }.onChange({ (row) in
					state.unit = DistanceUnit.items.index(of: row.value!) ?? 0
					self.prefManager.applyState(state)
					//                    let prop = PreferenceMeta(rawValue: 2)!
					//					  let index = DistanceUnit.items.index(of: row.value!)
					//                    defaults.set(index, forKey: prop.propertyName)
                })
			/*
            <<< SwitchRow() {
                    let prop = PreferenceMeta(rawValue: 3)!
                    $0.title = prop.description
                    $0.value = true
                    $0.value = (defaults.value(forKey: prop.propertyName) ?? prop.defaultValue) as? Bool
                }.onChange({ (row) in
                    let prop = PreferenceMeta(rawValue: 3)!
                    defaults.set(row.value, forKey: prop.propertyName)
                })
		*/
    }
}




