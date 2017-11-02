//
//  JourneyDetailMapView.swift
//  Myleholic
//
//  Created by Joe on 21.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import RealmSwift

@IBDesignable
class JourneyDetailLocationView: UIView {
	
	var contentView:UIView?
	@IBInspectable var nibName:String?
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var geoLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.nibSetup()
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.nibSetup()
		contentView?.prepareForInterfaceBuilder()
	}
	
	func nibSetup() {
		guard let view = self.instanceFromNib() else { return }
		view.frame = bounds
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(view)
		self.contentView = view
	}
	
	func instanceFromNib() -> UIView? {
		guard let _nibName = nibName else { return nil }
		
		let bundle = Bundle(for: type(of: self))
		return bundle.loadNibNamed(_nibName, owner: self)?.first as? UIView
	}
	
	func reloadPlace(_ pm: Placemark, current curr: CLPlacemark? = nil) {
		
		let loc = pm.location
		self.setupMap(loc)
		self.setupDistance(destination: pm, current: curr)
	}
	
	private func setupMap(_ location: CLLocation) {
		
		let coord = location.coordinate
		
		// pin
		let annotation = MKPointAnnotation()
		annotation.coordinate = coord
		self.mapView.addAnnotation(annotation)
		
		// region
		let span = MKCoordinateSpanMake(0.03, 0.03)
		let region = MKCoordinateRegionMake(coord, span)
		self.mapView.setRegion(region, animated: true)
		
		self.geoLabel.text = "\(coord.latitude)°, \(coord.longitude)°"
	}
	
	private func setupDistance(destination: Placemark, current: CLPlacemark? = nil) {
		
		self.distanceLabel.isHidden = current == nil
		
		guard let curr = current, let dest = PlacemarkParser.reverse(destination) else { return }
		
		let unitIndex = PreferenceManager.service.getState().unit
		let unitType = DistanceUnit(rawValue: unitIndex)!
		let unitDescription = unitType.abbreviation
		
		let distance: Double = DistanceCalculator.geoDistance(from: curr, to: dest, unit: unitType)
		self.distanceLabel.text = "\(String(format: "%.2f", distance)) \(unitDescription)"
		
	}
	
}
