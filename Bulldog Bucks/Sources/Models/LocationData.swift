//
//  LocationData.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 4/20/18.
//

import Foundation


struct Hours: Decodable {
    let monday: String
    let tuesday: String
    let wednesday: String
    let thursday: String
    let friday: String
    let saturday: String
    let sunday: String
}

struct Location: Decodable {
    let address: String
    let lat: Double
    let long: Double
}

enum LocationType: String, Decodable {
    case shopping
    case food
}

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

