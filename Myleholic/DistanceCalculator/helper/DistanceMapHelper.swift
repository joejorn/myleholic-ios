//
//  DistanceMapHelper.swift
//  Myleholic
//
//  Created by Joe on 05.10.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import MapKit

class DistanceMapHelper {
	
	func parseDistances(journies: [Journey], initialPlace: CLPlacemark, initialDate: Date) -> [JourneyAB] {
		
		// sort place by departure date and transform to TimeablePlacemark()
		let placemarks = journies.sorted(by: {
									$0.travels.first!.date < $1.travels.first!.date
								}).map{	JourneyPlacemark($0) }
		
		var arr = [JourneyAB]()
		var origins = [JourneyPlacemark]()
		
		// add initial hometown
		let initialOrigin = JourneyPlacemark(placemark: initialPlace, start: initialDate)
		origins.append(initialOrigin)
		
		placemarks.forEach({ pm in
			
			// pop the last element
			// until an active one or a one-way journey is found
			var prev = origins.popLast()!
			while ( prev.end != nil &&
					prev.end! < pm.start
				) {
				prev = origins.popLast()!
			}
			
			// enable link between origin & destination place
			// outbound journey
			arr.append(
				JourneyAB(
					id: pm.id,
					origin: prev.placemark,
					destination: pm.placemark,
					start: pm.start,
					enabled: true
				)
			)
			
			// return journey
			if pm.end != nil {
				arr.append(
					JourneyAB(
						id: pm.id,
						origin: pm.placemark,
						destination: prev.placemark,
						start: pm.end!,
						enabled: true
					)
				)
			}
			
			// the previous place can probably be active again
			// if the jouney has return
			if (pm.end != nil) {
				origins.append(prev)
			}
			
			origins.append(pm)
		})
		
		return arr
	}
	
	
	func parseJouneyPlacemarks(distances: [JourneyAB], initialPlace: CLPlacemark, initialDate: Date) -> [JourneyPlacemark] {
		let flatten = distances.map{ return [$0.origin, $0.destination] }.flatMap{ return $0 }
		let pms = Array( Set<CLPlacemark>(flatten) ).filter{ $0 != initialPlace }	// non-duplicate placemarks
		
		// parse placemark interval
		var jnPlacemarks = [JourneyPlacemark]()
		
		// initial place
		let initIntervals = getRawDateIntervals(for: initialPlace, from: distances, withDate: initialDate)
		let initPM = JourneyPlacemark(placemark: initialPlace, intervals: initIntervals)
		jnPlacemarks.append( initPM )
		
		// other places
		pms.forEach({ (placemark: CLPlacemark) in
			let intervals = getRawDateIntervals(for: placemark, from: distances)
			let pm = JourneyPlacemark.init(placemark: placemark, intervals: intervals)
			jnPlacemarks.append(pm)
		})
		
		return jnPlacemarks //pms
	}
	
	private func getRawDateIntervals(for placemark: CLPlacemark, from distances: [JourneyAB], withDate initialDate: Date?=nil) -> [JourneyDateInterval] {
		var intervals = [JourneyDateInterval]()
		var start: Date? = initialDate
		for i in 0..<distances.count {	// single loop thorugh the given sequence
			let jn = distances[i]
			if (start != nil) && (jn.origin == placemark) {	// find end
				intervals.append( JourneyDateInterval(start: start!, end: jn.start) )	// add interval
				start = nil
			} else if (start == nil) && (jn.destination == placemark) {	// find start
				start = jn.start
			}
		}
		
		if start != nil {
			intervals.append( JourneyDateInterval(start: start!, end: nil) )	// add interval
		}
		
		return intervals
	}
	
	func intersectsSome(_ dateInterval: DateInterval, intervals: [DateInterval]) -> Bool {
		for i in 0..<intervals.count {
			if (dateInterval.intersects(intervals[i])) {
				return true
			}
		}
		return false
	}
	
	
	func parseOverlays(distances: [JourneyAB], places nodes: [CLPlacemark]) -> [MKOverlay] {
		
		guard nodes.count > 0, distances.count > 0 else { return [] }
		
		let edgeSeparator = ":"
		var edgeIdSet = Set<String>()	// pair of indexes as a word: "a:b"
		var edges = [Array<CLLocationCoordinate2D>]()
		
		distances.forEach({ journey in
			
			let pms = [journey.origin, journey.destination]
			
			guard 	let originId = nodes.index(of: pms[0]),
					let destId = nodes.index(of: pms[1])
				else { return }
			
			// pair place indexes as edge
			let nodeIndexes = [originId, destId]
			let edgeIds = [nodeIndexes, nodeIndexes.reversed()]
			let edgeStrIds = edgeIds.map({
				indexes -> String in
				return indexes.map{String($0)}.joined(separator: edgeSeparator)
			})
			
			// check availability of edge
			let foundEdge = edgeIdSet.intersection( Set<String>(edgeStrIds) )
			if foundEdge.capacity < 1 {
				edgeIdSet.insert(edgeStrIds.first!)	// add new edge
				edges.append( pms.map{ return $0.location!.coordinate } )
			}
		})
		
		return edges.map({ return MKGeodesicPolyline(coordinates: $0, count: 2) })
	}

}

/*
// remove return routes
var prevId = -1
let outJns = distances.filter{
let isReturn = ($0.id == prevId)
if  !isReturn {
prevId = $0.id
}
return !isReturn
}
*/
