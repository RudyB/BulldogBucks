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

    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var callStackView: UIStackView!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var websiteStackView: UIStackView!
    @IBOutlet weak var websiteAddressButton: UIButton!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var menuAdressButton: UIButton!

    var venue: LocationData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(
            width: stackView.frame.width,
            height: stackView.frame.height + 25
        )
    }

    func setupView() {
        addMapAnnotations()
        setMapRegion()

        guard let venue = venue else { return }
        titleLabel.text = venue.name
        categoryLabel.text = venue.category.rawValue.capitalized
        addressLabel.text = venue.location.address
        phoneNumberButton.setTitle(venue.formattedPhone, for: .normal)
        phoneNumberButton.addTarget(self, action: #selector(callVenue(_:)), for: .touchUpInside)

        if let website = venue.url {
            websiteAddressButton.setTitle(website.absoluteString, for: .normal)
            websiteAddressButton.addTarget(self, action: #selector(openURL(_:)), for: .touchUpInside)
            self.websiteStackView.isHidden = false
        } else {
            self.websiteStackView.isHidden = true
        }

        if let menu = venue.menuUrl {
            menuAdressButton.setTitle(menu.absoluteString, for: .normal)
            menuAdressButton.tag = 1
            menuAdressButton.addTarget(self, action: #selector(openURL(_:)), for: .touchUpInside)
            self.menuStackView.isHidden = false
        } else {
            menuStackView.isHidden = true
        }
    }

    @IBAction func openURL(_ sender: UIButton) {
        guard let url = sender.title(for: .normal) else { return }

        let webView = storyboard?.instantiateViewController(withIdentifier: WebViewController.storyboardIdentifier) as! WebViewController
        webView.url = url
        webView.title = sender.tag == 1 ? "Menu" : "Website"
        present(webView, animated: true, completion: nil)
    }

    @IBAction func callVenue(_ sender: UIButton) {
        print("Attempt to call venue")
        guard
            let venue = venue,
            let number = URL(string: "tel://" + venue.phone)
        else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(number)
        } else {
            UIApplication.shared.openURL(number)
        }
    }

}

// MARK: MKMAPViewDelegate

extension DetailViewController: MKMapViewDelegate {

    func addMapAnnotations() {
        removeMapAnnotations()

        let point = MKPointAnnotation()
        guard let venue = venue else { return }
        point.coordinate = CLLocationCoordinate2D(latitude: venue.location.lat, longitude: venue.location.long)
        point.title = venue.name
        mapView.addAnnotation(point)
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
