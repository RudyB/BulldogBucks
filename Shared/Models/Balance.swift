//
//  Balance.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 10/2/17.
//

import Foundation

struct Balance: Codable {

    fileprivate let balance: Double
    fileprivate let rawBalance: String

    init(balance: Double) {
        self.balance = balance
        self.rawBalance = String(balance)
    }

    init?(rawBalance: String) {

        let filteredBalance = rawBalance
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")

        guard let balanceAsDouble = Double(filteredBalance) else {
                return nil
        }
        self.balance = balanceAsDouble
        self.rawBalance = filteredBalance

    }

    var value: Double {
        return balance
    }

    var rawValue: String {
        return rawBalance
    }

    var prettyBalance: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        return numberFormatter.string(from: NSNumber(value: balance))!
    }

    var shortTextBucksForComplication: String {
        return rawBalance.components(separatedBy: ".")[0]
    }

    var longTextBucksForComplication: String {
        return rawBalance
    }

}
