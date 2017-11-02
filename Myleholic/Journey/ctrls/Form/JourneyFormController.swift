//
//  JourneyFormController.swift
//  Airholic
//
//  Created by Joe on 28.08.17.
//
//

import Foundation
import Eureka
import MapKit
import SwiftIconFont

class JourneyFormController: FormViewController {
	
    var jnManager = JourneyManager.service
	
	// initial form data
	var journey: Journey?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.rightBarButtonItem?.isEnabled = false
		self.setupForm()
    }
	
	private func setupForm() {
		
		form
			+++ Section()
			<<< LocationRow(JourneyFormMeta(rawValue: 0)!.propertyName) {
				let prop = JourneyFormMeta(rawValue: 0)!
				$0.title = prop.description
			}.onChange{ row in
					self.navigationItem.rightBarButtonItem?.isEnabled = row.value != nil
			}
			
			// two-way journey
			<<< SwitchRow(JourneyFormMeta(rawValue: 1)!.propertyName) {
				let prop = JourneyFormMeta(rawValue: 1)!
				$0.title = prop.description
				$0.value = true
			}
			
			+++ Section("Outbound")
			
			// start date
			<<< DateInlineRow(JourneyFormMeta(rawValue: 2)!.propertyName){
				let prop = JourneyFormMeta(rawValue: 2)!
				$0.title = prop.description
				$0.value = Date()
			}
			
			<<< TimeInlineRow(JourneyFormMeta(rawValue: 3)!.propertyName){
				let prop = JourneyFormMeta(rawValue: 3)!
				$0.title = prop.description
				$0.value = Date()
			}
			
			+++ Section("Return") {
				let switchTag = JourneyFormMeta(rawValue: 1)!.propertyName
				$0.hidden = Condition.function([switchTag], {form in
					guard let row = form.rowBy(tag: switchTag) as? SwitchRow else {return false}
					return !(row.value ?? true)
				})
			}
			
			// return date
			<<< DateInlineRow(JourneyFormMeta(rawValue: 4)!.propertyName){
				let prop = JourneyFormMeta(rawValue: 4)!
				$0.title = prop.description
				$0.value = Date()
			}
			
			<<< TimeInlineRow(JourneyFormMeta(rawValue: 5)!.propertyName){
				let prop = JourneyFormMeta(rawValue: 5)!
				$0.title = prop.description
				$0.value = Date()
			}
			
			+++ Section(){ $0.hidden = Condition.init(booleanLiteral: self.journey == nil) }
			// remove journey
			<<< ButtonRow() {
					$0.title = "Delete journey"
				}.cellSetup { cell, row in
					cell.tintColor = UIColor.red
				}.onCellSelection{ cell, row in
					self.onRemoveJourney( cell )
		}
		
		if 	let _values = JourneyFormHelper.extractFormValues(journey) {
			form.setValues(_values)
		}
		
	}
	
    
    @IBAction func onDismissForm(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitForm(_ sender: Any) {
		let formObj = JourneyFormHelper.parseFormValues(form.values(includeHidden: false))
		jnManager.setJourney(journey, withValues: formObj)
        self.dismiss(animated: true, completion: nil)
    }
	
	private func onRemoveJourney(_ sender: Any) {
		
		guard let jn = self.journey else { return }
		
		let alertDescription = "Are you sure your want to delete this journey permanently?"
		
		let alert = UIAlertController(title: "Delete Journey", message: alertDescription, preferredStyle: .alert)
		
		// ok button
		alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
			self.jnManager.removeJourney(jn)
			self.onDismissForm( sender )
		}))
		
		// cancel button
		alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Default action"), style: .cancel, handler: nil) )
		
		self.present(alert, animated: true, completion: nil)
	}

}
