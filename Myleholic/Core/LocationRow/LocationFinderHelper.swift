//
//  LocationFinderHelper.swift
//  Airholic
//
//  Created by Joe on 27.08.17.
//
//

import Foundation
import MapKit

class LocationFinder {
    
    private var activeLocationHelper = ActiveLocationManager.service
    
    func searchPlaces( query: String?, region: MKCoordinateRegion?, completionHandler: @escaping (_ items:[MKMapItem]) -> Void ) {
        if (query != "") {
            let localReq = MKLocalSearchRequest()
            localReq.naturalLanguageQuery = query
            
            // current region if available
            if (self.activeLocationHelper.region != nil) && (region == nil) {
                localReq.region = self.activeLocationHelper.region!
            }
            
            let localSearch = MKLocalSearch(request: localReq)
            localSearch.start( completionHandler: {(response, error) in
                guard error == nil else { return }
                completionHandler(response!.mapItems)
            })
        }
        
    }
    
}
