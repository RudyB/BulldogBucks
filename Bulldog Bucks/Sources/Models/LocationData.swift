//
//  LocationData.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 4/20/18.
//

import Foundation

/// Models the hours of operation for shops/restaurants
struct Hours: Decodable {

    /// Hours of Operation for Monday
    let monday: String

    /// Hours of Operation for Tuesday
    let tuesday: String

    /// Hours of Operation for Wednesday
    let wednesday: String

    /// Hours of Operation for Thursday
    let thursday: String

    /// Hours of Operation for Friday
    let friday: String

    /// Hours of Operation for Saturday
    let saturday: String

    /// Hours of Operation for Sunday
    let sunday: String
}

/// Models the properties of a physcial location
struct Location: Decodable {

    /// Street Address Component
    let address: String

    /// Latitude Component
    let lat: Double

    /// Longitude Compontent
    let long: Double
}

/// Models the type of Location
///
/// - retail: Retail Locations
/// - dining: Dining / Food Locations
enum LocationType: String, Decodable {
    case retail
    case dining
}

/// Model used to Decode Location data from server
struct LocationData: Decodable {
    let name: String
    let description: String
    let hours: Hours
    let phone: String
    let formattedPhone: String
    let location: Location
    let url: URL?
    let menuUrl: URL?
    let category: LocationType

    /// CodingKeys are the names of the json component, so that they can be properly mapped to the LocationData model
    enum CodingKeys: String, CodingKey {
        case name
        case description = "desc"
        case hours
        case phone
        case formattedPhone = "formatted-phone"
        case location
        case url
        case menuUrl = "menu-url"
        case category
    }
}
