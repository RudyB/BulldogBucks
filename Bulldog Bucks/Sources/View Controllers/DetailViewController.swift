//
//  DetailViewController.swift
//  Health Care Near Me
//
//  Created by Rudy Bermudez on 5/1/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit
import MapKit


class DetailViewController: UIViewController {
	
	public static let storyboardID: String = "detailViewController"
	
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var checkinsLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var callStackView: UIStackView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var websiteStackView: UIStackView!
    @IBOutlet weak var websiteAddressLabel: UILabel!
    
	

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        addMapAnnotations()
        setMapRegion()
        
    }
	

}

// MARK: MKMAPViewDelegate

extension DetailViewController: MKMapViewDelegate {
    
    
    func addMapAnnotations() {
        removeMapAnnotations()
        
        let point = MKPointAnnotation()
        
    }
    

    func removeMapAnnotations() {
        if mapView.annotations.count != 0 {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    func setMapRegion() {
        guard let annotationLocation = mapView.annotations.first?.coordinate else {
            return
        }
        var region = MKCoordinateRegion()
        region.center = annotationLocation
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        mapView.setRegion(region, animated: false)
        
    }
}
