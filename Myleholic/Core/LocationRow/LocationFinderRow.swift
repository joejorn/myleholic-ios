//
//  LocationFinderController.swift
//  Airholic
//
//  Created by Joe on 27.08.17.
//
//

import Foundation
import CoreLocation
import MapKit
import Eureka


public final class LocationRow: OptionsRow<PushSelectorCell<MKPlacemark>>, PresenterRowType, RowType {
    
    public typealias PresenterRow = LocationFinderController
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
	
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(
            controllerProvider: ControllerProvider.callback { return LocationFinderController(){ _ in } },
            onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let place = $0 else { return "" }
            return PlacemarkFormatter.getTitle(place)
        }
    }
    
    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

public class LocationFinderController : UIViewController, TypedRowControllerType {
    
    public var row: RowOf<MKPlacemark>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    var tableCtrl  = LocationResultTableController()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableCtrl.tableView)
        
        let searchBar = UISearchBar()
        
        searchBar.delegate = tableCtrl
        tableCtrl.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.sizeToFit()
        searchBar.placeholder = "Enter a place (e.g. Cupertino)"
        searchBar.text = row.value?.name ?? ""
        
        self.definesPresentationContext = true
        
        searchBar.becomeFirstResponder()
        tableCtrl.tableView.tableHeaderView = searchBar

        navigationItem.title = "Place"
    }
    
    
    func onReturnPlace(_ place: MKPlacemark){
        row.value = place
        onDismissCallback?(self)
    }
}


