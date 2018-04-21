//
//  LocationResultsViewController.swift
//  Health Care Near Me
//
//  Created by Rudy Bermudez on 4/30/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit
import MapKit

class LocationResultsViewController: UIViewController {
    
    public static let storyboardIdentifier: String = "LocationResultsViewController"

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    var coordinate: Coordinate?
    
    let manager = LocationManager()
    
    let searchController = UISearchController(searchResultsController: nil)
	
	var regionHasBeenSet = false
    
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		// Search bar configuration
		searchController.searchResultsUpdater = self
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.isTranslucent = false
		definesPresentationContext = true
		stackView.insertArrangedSubview(searchController.searchBar, at: 0)
		self.view.layoutIfNeeded()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 238.0/255.0, green: 37.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
		
		manager.getPermission()
        manager.onLocationFix = { [weak self] coordinate in
            
            self?.coordinate = coordinate
           
        }
    }

}

extension LocationResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        // TODO: Rudy - Add functionality, name, description, category etc
        cell.LocationTitleLabel.text = ""
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
		let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.storyboardID) as! DetailViewController
		
        navigationController?.pushViewController(vc, animated: true)
	}
    
}




// MARK: MKMAPViewDelegate

extension LocationResultsViewController: MKMapViewDelegate {
    
    
    func addMapAnnotations() {
        removeMapAnnotations()
        
        
    }
    
    func removeMapAnnotations() {
        if mapView.annotations.count != 0 {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
        }
    }

    func setMapRegion() {
        var region = MKCoordinateRegion()
        region.center = mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.03
        region.span.longitudeDelta = 0.03
        mapView.setRegion(region, animated: false)
        
    }
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		if !regionHasBeenSet {
            regionHasBeenSet = true
			setMapRegion()
		}
	}
 
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotations = view.annotation?.title, let title = annotations else {
            return
        }
       
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotations = view.annotation?.title, let title = annotations else {
            return
        }
       
    }
}

// MARK: UISearchResultsUpdating

extension LocationResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
}
