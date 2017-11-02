//
//  JourneyListTableViewController.swift
//  Myleholic
//
//  Created by Joe on 30.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import UIKit
import MapKit.MKPlacemark
import RealmSwift
import SwiftIconFont

class JourneyListTableViewController: UITableViewController {
	
	var notificationToken: NotificationToken? = nil

	var travelService = TravelManager.service
	var travels: Results<Travel>!
	
	var activeTownFinder = ActiveTownFinder()

	private var _sections : [Int] = []
	private var _dataset: [Int: Array<Journey>] = [:]	// grouped by year
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Journey"	// title on navigation bar
		navigationController?.title = "Journey"	// title on tab bar
		
		self.travels = self.travelService.getOutboundTravels()
		self.notificationToken = self.travels.observe { (changes: RealmCollectionChange) in
			switch changes {
			case .initial, .update(_):
				self.reloadDataset()
				self.tableView.reloadData()
				break
				
			case .error(let error):
				// An error occurred while opening the Realm file on the background worker thread
				fatalError("\(error)")
				break
			}
		}
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// clear all selection
		if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: selectionIndexPath, animated: false)
		}
	}
	
	
	deinit {
		self.notificationToken?.invalidate()
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "detail-segue" {
			if let cellIndexPath = tableView?.indexPath(for: sender as! UITableViewCell) {
				let destination = segue.destination as! JourneyDetailTableViewController
				
				let sectionId = self._sections[cellIndexPath.section]
				if let journies = self._dataset[sectionId] {
					let jn = journies[cellIndexPath.row]
					destination.journey = jn
					destination.origin = activeTownFinder.getActiveTown(jn.travels.first!.date)
				}
			}
		}
	}
	
	// prepare model
	func reloadDataset() {
		
		self._dataset = [:]	// clear content
		let sortedTravels = self.travels.sorted(byKeyPath: "date", ascending: false)
		
		// prepare sections
		let _calendar = Calendar.current
		let _years = sortedTravels.map({ _calendar.component(.year, from: $0.date) })
		self._sections = Set<Int>(_years).sorted(by: >)
		self._sections.forEach({ self._dataset[$0] = [] })
		
		// prepare content
		sortedTravels.forEach({ travel in
			let year = _calendar.component(.year, from: travel.date)
			self._dataset[year]!.append(travel.owner)
		})
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self._dataset.keys.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return (self._sections.count > 0) ? String( describing: self._sections[section] ) : "untitled"
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard self._sections.count > section else { return 0 }
		let selectedKey = self._sections[section]
		return self._dataset[selectedKey]?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "item-cell")!
		
		let selectedKey = self._sections[indexPath.section]
		if let journies = self._dataset[selectedKey] {
			let jn = journies[indexPath.row]
			let place = jn.place!
			cell.textLabel?.text = place.name
			cell.detailTextLabel?.text = place.shortAddress //"\(place.locality!), \(place.country)"
		}
		
		return cell
	}
	
}
