//
//  JourneyDetailTableViewController.swift
//  Myleholic
//
//  Created by Joe on 26.09.17.
//  Copyright © 2017 Joe. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

class JourneyDetailTableViewController: UITableViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	
	fileprivate var activeLocationHelper = ActiveLocationManager.service
	
	var journey: Journey?
	var origin: CLPlacemark!
	var notifications : [NotificationToken] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// navigation
		self.navigationItem.title = self.journey?.place?.name ?? ""
		
		// dynamic row height
		self.tableView.estimatedRowHeight = 44.0
		self.tableView.rowHeight = UITableViewAutomaticDimension
		
		self.setUpHeader()
		tableView.tableFooterView = UIView(frame: .zero)
		
		// notification
		if (self.journey != nil) {
			self.notifications.append(
				self.journey!.observe { change in
					switch change {
					case .change(let properties):
						for property in properties {
							if property.name == "place" {
								self.setUpHeader()
							}
						}
						break
					case .error(let error):
						print("An error occurred: \(error)")
						break
					case .deleted:
						print("The object was deleted.")
						self.navigationController?.popViewController(animated: true)
						break
					}
				}
			)
		}
	}
	
	deinit {
		for token in self.notifications {
			token.invalidate()
		}
	}
	
	/* Resizing table header view */
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		guard let header = tableView.tableHeaderView else { return }
		
		let size = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
		
		if header.frame.size.height != size.height {
			header.frame.size.height = size.height
			tableView.tableHeaderView = header
			tableView.layoutIfNeeded()
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let segueId = segue.identifier else {return}
		
		if (segueId == "edit-segue") {
			let destination = segue.destination as! UINavigationController
			let formCtrl = destination.viewControllers.first as! JourneyFormController
			
			if let jn = self.journey {
				formCtrl.journey = jn
			}
		}
	}
	
	private func setUpHeader() {
		
		let _title = journey?.place?.name ?? ""
		self.titleLabel.text = _title.uppercased()
		self.tableView.allowsSelection = false

		self.subtitleLabel.text = journey?.place?.shortAddress ?? ""
	}
	
	
	func setupTimetableView(_ cell: UITableViewCell, departure: Date, from originTitle: String, to destTitle: String) {
		let dateLabel = cell.viewWithTag(10) as! UILabel
		dateLabel.text = DateFormatter.localizedString(from: departure, dateStyle: .long, timeStyle: .none)
		
		let timeFormatter = DateFormatter()
		timeFormatter.setLocalizedDateFormatFromTemplate("HH:mm") // set template after setting locale
		
		let timeLabel = cell.viewWithTag(11) as! UILabel
		timeLabel.text = timeFormatter.string(from: departure)
		
		let originPlaceLabel = cell.viewWithTag(20) as! UILabel
		originPlaceLabel.text = originTitle
		
		let destPlaceLabel = cell.viewWithTag(21) as! UILabel
		destPlaceLabel.text = destTitle
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	/* Header */
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44.0
	}
	
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.backgroundView?.backgroundColor = UIColor.clear
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let _title = section < 1 ? "Location" : "Departure"
		return _title//.uppercased()
	}
	
	/* Footer for additional space */
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return section < 1 ? 16.0: 0.0
	}
	
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		let footer = view as! UITableViewHeaderFooterView
		footer.backgroundView?.backgroundColor = UIColor.clear
	}
	
	/* Rows */
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section < 1 ? 1 : self.journey?.travels.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return indexPath.section < 1 ? 200.0 : UITableViewAutomaticDimension
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let jn = self.journey else { return UITableViewCell(style: .default, reuseIdentifier: "cell") }
		
		var cell: UITableViewCell!
		
		if (indexPath.section < 1) {	// location
			
			cell = tableView.dequeueReusableCell(withIdentifier: "location-cell")
			
			if let locationView = cell.viewWithTag(10) as? JourneyDetailLocationView {
				locationView.reloadPlace(self.journey!.place!, current: MKPlacemark(placemark: origin) )
			}
			
		} else {	// timetable
			
			cell = tableView.dequeueReusableCell(withIdentifier: "timetable-cell")
			
			let travel = jn.travels[indexPath.row]
			let untitled = "Untitled"
			let placeA = origin.name ?? untitled
			let placeB = jn.place?.name ?? untitled
			
			if (indexPath.row < 1) {
				self.setupTimetableView(cell, departure: travel.date, from: placeA, to: placeB)
			} else {
				self.setupTimetableView(cell, departure: travel.date, from: placeB, to: placeA)
			}
		}
		
		return cell
		
	}
}
