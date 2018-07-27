//
//  LocationAPI.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 4/20/18.
//

import Foundation
import Alamofire

/// Class that handles requesting the locations that accept Bulldog Bucks
class LocationAPI {

    /// Enum that models potential errors
    ///
    /// - failToDecodeJSON: error thrown when the json cannot be decoded
    enum LocationAPIError: Error {
        case failToDecodeJSON
    }

    /// Function that handles requesting the location json, and converting it to LocationData
    ///
    /// - Parameter onCompletion: Closure that contains the outcome of the request
    static func getLocations(onCompletion: @escaping (Result<[LocationData]>) -> Void ) {

        let locationJSONurl = "https://raw.githubusercontent.com/RudyB/BulldogBucks/master/locations.json"
        Alamofire.request(locationJSONurl).validate().responseData { (response) in
            switch response.result {
            case .failure(let error): onCompletion(.failure(error))
            case .success(let data):
                guard
                    let locationData = try? JSONDecoder().decode([LocationData].self, from: data)
                else {
                    onCompletion(.failure(LocationAPI.LocationAPIError.failToDecodeJSON))
                    return
                }
                onCompletion(.success(locationData))
            }
        }
    }
}
