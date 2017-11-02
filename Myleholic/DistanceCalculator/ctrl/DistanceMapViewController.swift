//
//  DistanceMapViewController.swift
//  Myleholic
//
//  Created by Joe on 29.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

class DistanceMapViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var filterButton: UIButton!
	
	var helper = DistanceMapHelper()
	var prefManager = PreferenceManager.service
	
	// journey data API
	var jnManager = JourneyManager.service
	var journeys: Results<Journey>!
	var notificationToken: NotificationToken?
	
	// statements
	var prefState : PreferenceState!
	var filterInterval: FilterInterval! // = FilterInterval.currentYear
	var jnPlacemarks = [JourneyPlacemark]()
	var jnABs = [JourneyAB]()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let _state = prefManager.getState()
		if 	(prefState.homeplace != _state.homeplace) ||
			(prefState.homeStart != _state.homeStart) {
			prefState = _state
			reload()
		} else if (prefState.unit != _state.unit) {
			prefState = _state
			renderCounter()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// shadow UI elements
		let floatElements: [UIView] = [filterButton, distanceLabel]
		for i in 0..<floatElements.count {
			let elem = floatElements[i]
			elem.layer.shadowRadius = 3.0
			elem.layer.shadowColor = UIColor.lightGray.cgColor
			elem.layer.shadowOffset = CGSize(width: 0, height: 1)
			elem.layer.shadowOpacity = 0.3
		}
		
		prefState = prefManager.getState()
		applyFilterInterval(FilterInterval.currentYear)	// default filter
		
		journeys = jnManager.getJournies()
		notificationToken = journeys.observe {
			(changes: RealmCollectionChange) in
				switch changes {
				case .initial, .update(_):
					self.reload()
					break
					
				case .error(let error):
					// An error occurred while opening the Realm file on the background worker thread
					fatalError("\(error)")
					break
				}
		}
	}
	
	deinit {
		notificationToken?.invalidate()
	}
	
	@IBAction func showFilterSelection(_ sender: Any) {
		
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let filters = FilterInterval.catalog
		filters.forEach{
			let action = UIAlertAction(title: $0, style: .default, handler: { sender in
				let interval = FilterInterval(rawValue: filters.index(of: sender.title!) ?? 0)!
				self.applyFilterInterval(interval)
			})
			if ($0 == filterInterval.description) {
				action.isEnabled = false
			}
			actionSheet.addAction(action)
		}
		
		// cancel button
		let dismissBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		actionSheet.addAction(dismissBtn)
		
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	
	func applyFilterInterval(_ newFilter: FilterInterval) {
		if filterInterval != newFilter {
			filterInterval = newFilter
			filterButton.setTitle(filterInterval.description + "  ▾", for: UIControlState.normal)
			renderUI()
		}
	}
	
	// query and return a journey snapshot
	func getJourneysSnapshot(_ journeys: Results<Journey>) -> [Journey] {
		var arr = [Journey]()
		journeys.forEach{
			arr.append($0)
		}
		return arr
	}
	
	func reload() {
		// (re-)load all journies
		let jns = self.getJourneysSnapshot(self.journeys)
		self.jnABs = self.helper.parseDistances(journies: jns, initialPlace: self.prefState.homeplace, initialDate: self.prefState.homeStart)
		self.jnPlacemarks = self.helper.parseJouneyPlacemarks(distances: self.jnABs, initialPlace: self.prefState.homeplace, initialDate: self.prefState.homeStart)
		self.renderUI()
	}
	
	func renderUI() {
		let interval = filterInterval.interval
		
		// recalculate placemarks
		for i in 0..<jnPlacemarks.count {
			let pm = jnPlacemarks[i]
			let intervals = pm.intervals.map{ DateInterval(start: $0.start, end: $0.end ?? Date.distantFuture) }
			jnPlacemarks[i].enabled = helper.intersectsSome(interval, intervals: intervals)
		}
		
		for i in 0..<jnABs.count {
			jnABs[i].enabled = interval.contains(jnABs[i].start)
		}
		
		renderMap()
		renderCounter()
	}
	
	func renderMap() {
		
		let pms = jnPlacemarks.filter{ $0.enabled }.map{ $0.placemark }
		
		// annotations
		mapView.removeAnnotations(mapView.annotations)
		let annotations = pms.map{ MKPlacemark(placemark: $0) }
		mapView.addAnnotations(annotations)
		
		// routes
		mapView.removeOverlays(mapView.overlays)
		let overlays = helper.parseOverlays(distances: jnABs, places: pms)
		mapView.addOverlays(overlays)
	}
	
	func renderCounter() {
		let sum: Double = jnABs.reduce(0.0, { (x: Double, y: JourneyAB) in
			x + ( y.enabled ? y.distance : 0.0)
		})
		
		let unitType = DistanceUnit(rawValue: prefState.unit)!
		let unitSum = DistanceCalculator.convert(sum, to: unitType)
		
		// locale formatter
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.locale = Locale(identifier: Locale.current.identifier)
		let result = formatter.string(from: unitSum as NSNumber) ?? "0"
		
		distanceLabel.text = "\(result) \(unitType.abbreviation)"
	}

}

extension DistanceMapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MKPolyline  else { return MKOverlayRenderer() }
		
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.lineWidth = 1.0
		renderer.alpha = 0.75
		renderer.strokeColor = distanceLabel.textColor
		
		return renderer
	}
	
}
