//
//  LocationAPI.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 4/20/18.
//

import Foundation
import Alamofire

class LocationAPI {
    
    enum LocationAPIError: Error {
        case failToDecodeJSON
    }
    
    static func getLocations(onCompletion: @escaping (Result<[LocationData]>) -> Void ) {
        
        
        let locationJSONurl = "https://raw.githubusercontent.com/RudyB/BulldogBucks/feature/locations/locations.json"
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
