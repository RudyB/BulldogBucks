//
//  ZagwebDataSet.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 8/27/17.
//
//

import Foundation

final class ZagwebDataSet: Codable {
    
    let bucksRemaining: Balance
    let swipesRemaining: String
    let date: Date
    
    init(bucksRemaining: Balance, swipesRemaining: String,  date: Date) {
        self.bucksRemaining = bucksRemaining
        self.date = date
        self.swipesRemaining = swipesRemaining
    }
    
}

