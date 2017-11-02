//
//  UserLocationHelper.swift
//  Airholic
//
//  Created by Joe on 28.08.17.
//
//

import Foundation
import MapKit

final class ActiveLocationManager: NSObject {
    
	fileprivate var _locationManager: CLLocationManager!
	
    public var location: CLLocation? {
		return self._locationManager.location
	}
	
    fileprivate var _place: MKPlacemark?
    public var place: MKPlacemark? {
		return self._place
	}
	
    public var region: MKCoordinateRegion? {
        get {
            guard let place = self._place else { return nil }
			
            let radius = 5000.0   // constant for a region
            return MKCoordinateRegionMakeWithDistance(place.coordinate, CLLocationDistance(radius), CLLocationDistance(radius))
        }
    }
	
	static let service = ActiveLocationManager()
	
	private override init() {
		super.init()
		
		self._locationManager = CLLocationManager()
		self._locationManager.delegate = self
		self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self._locationManager.requestWhenInUseAuthorization()
		self._locationManager.requestLocation()
	}
    
    private func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        
        // Use the last reported location.
        if let lastLocation = self._locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(
                lastLocation,
                completionHandler: { (placemarks, error) in
                    if error == nil {
						
						if let firstLocation = placemarks?.first {
							completionHandler(firstLocation)
						}
                    } else {
                        // An error occurred during geocoding.
                        completionHandler(nil)
                    }
                }
            )
            
        } else {
            // No location was available.
            completionHandler(nil)
        }
    }

}

extension ActiveLocationManager: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.lookUpCurrentLocation(completionHandler: { (clPlacemark) in
			guard let pm = clPlacemark else { return }
			self._place = MKPlacemark(placemark: pm)
		})
	}
	
	private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.requestLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error: \(error)")
	}
	
}
