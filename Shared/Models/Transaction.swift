//
//  Transaction.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 9/2/17.
//
//

import Foundation

enum TransactionType: String, Codable {
    case sale
    case deposit
    case `return`
}

struct Transaction: Codable {

    let date: Date

    let venue: String

    let amount: Double

    let type: TransactionType

    init?(date: String, venue: String, amount: String, type: String) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"

        guard let amountDouble = Double(amount
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            ),
            let formattedDate = dateFormatter.date(from: date),
            let transactionType = TransactionType(rawValue: type.lowercased()) else {
            return nil
        }

        self.amount = amountDouble
        self.venue = venue
            .replacingOccurrences(of: "UD ", with: "")
            .replacingOccurrences(of: "BbOne ", with: "")
            .replacingOccurrences(of: " API", with: "")
        self.date = formattedDate
        self.type = transactionType
    }

}

extension Transaction: CustomStringConvertible {
    var description: String {
        return "\n\(prettyDate)  \(venue)  \(prettyAmount)"
    }

    var prettyDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy hh:mm a"
        return dateFormatter.string(from: date)
    }

    // Just the date without the time
    var dateForSorting: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"

        let dateWithoutTime = dateFormatter.string(from: date)

        return dateFormatter.date(from: dateWithoutTime)!
    }

    var sectionHeaderDate: String {
        if Calendar.current.compare(dateForSorting, to: Date(), toGranularity: .day) == .orderedSame {
            return "Today"
        } else if (dateForSorting as NSDate).days(to: Date()) == 1 {
            return "Yesterday"
        } else if Calendar.current.compare(dateForSorting, to: Date(), toGranularity: .year) == .orderedSame {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d"
            return dateFormatter.string(from: dateForSorting)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter.string(from: dateForSorting)
        }

    }

    var prettyAmount: String {
        switch type {
        case .deposit:
            return String(format: "+$%.2f", amount)
        case .sale:
            return String(format: "-$%.2f", amount)
        case .return:
            return String(format: "+$%.2f", amount)
        }
    }
}
