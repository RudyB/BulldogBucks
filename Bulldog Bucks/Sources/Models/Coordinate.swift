//
//  Coordinate.swift
//  Health Care Near Me
//
//  Created by Rudy Bermudez on 5/1/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import Foundation

/// Models Coordinates
struct Coordinate {

    /// Latitude Component
    let latitude: Double

    /// Longitude Component
    let longitude: Double
}

extension Coordinate: CustomStringConvertible {

    /// Formats latitude and longitude in a human readable format
    var description: String {
        return "\(latitude),\(longitude)"
    }
}
