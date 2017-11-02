//
//  LocationResultTable.swift
//  Airholic
//
//  Created by Joe on 27.08.17.
//
//

import Foundation
import MapKit
import UIKit

public class LocationResultTableController: UITableViewController {
    
    var delegate: LocationFinderController?
    var finderHelper: LocationFinder!
    var dataset: [MKPlacemark] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0)
        self.finderHelper = LocationFinder()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataset.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let place = self.dataset[indexPath.row]
        cell.textLabel?.text = place.name ?? "Untitled"
        cell.detailTextLabel?.text = PlacemarkFormatter.getFullAddress(place)
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _delegate = self.delegate else { return }
        
        let selected = self.dataset[indexPath.row]
        _delegate.onReturnPlace(selected)
    }
    
}

extension LocationResultTableController: UISearchBarDelegate {
    
    private func searchAndReload(searchText: String) {
        
        self.finderHelper.searchPlaces(query: searchText, region: nil, completionHandler: { (mapItems) in
            self.dataset = mapItems.map{$0.placemark}
            self.tableView.reloadData()
        })
        
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        self.searchAndReload(searchText: searchText)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchAndReload(searchText: searchText)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.resignFirstResponder()
    }
}
