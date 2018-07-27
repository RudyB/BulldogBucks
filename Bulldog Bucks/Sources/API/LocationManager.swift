//
//  LocationManager.swift
//  Stratus
//
//  Created by Rudy Bermudez on 3/19/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import Foundation
import CoreLocation

// Extenion used to convert a CLLocation to a Coordinate
extension Coordinate {
    init(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}

/// The LocationManager handles querying the user's location
final class LocationManager: NSObject, CLLocationManagerDelegate {

    /// CLLocationManager responsible for API Calls
	let manager = CLLocationManager()

    /// Error Domain Code
	let errorDomain = "io.rudybermudez.bulldogbucks.LocationManager"

    /// Closure function that will contain the user's coordinates
	var onLocationFix: ((Coordinate) -> Void)?

    /// Initialize Locationmanager
	override init() {
		super.init()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		manager.requestLocation()
	}

    /// Handles requesting the user for permission to use their location
	func getPermission() {
		if CLLocationManager.authorizationStatus() == .notDetermined {
			manager.requestWhenInUseAuthorization()
		}
	}

    /// Requests a new update of the user's location
	func updateLocation() {
		manager.requestLocation()
	}

	// MARK: CLLocationManagerDelegate

    /// CLLocationManager Delegate function that gets called when the user changes CLAuthorizationStatus
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.requestLocation()
		}
	}

    /// CLLocationManager Delegate function
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}

    /// CLLocationManager Delegate function that is called when a new location update is availible
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		guard let location = locations.first else { return } // Make sure a location is availible

        let coordinate = Coordinate(location: location) // Create a coordinate object from the CLLocation

        if let onLocationFix = onLocationFix { // Check to make sure that someone has defined a function that handles receiving a location
            onLocationFix(coordinate) // send the location to the closure
        }
	}
}
