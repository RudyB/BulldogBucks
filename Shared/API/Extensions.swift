//
//  Extensions.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 11/21/16.
//
//

import UIKit

extension NSDate {

    /**
     Creates a pretty printed `String` representation of the difference in time from `timeIntervalSinceNow` to the time initialized in the instance of NSDate.
     */
	var timeAgoInWords: String {
		let intervalInSeconds = fabs(timeIntervalSinceNow)
		let intervalInMinutes = round(intervalInSeconds / 60.0)

		if intervalInMinutes >= 0 && intervalInMinutes <= 1 {
			if intervalInSeconds >= 0 && intervalInSeconds < 5 {
				return "just now"
			} else if intervalInSeconds >= 5 && intervalInSeconds < 60 {
				return "\(Int(intervalInSeconds)) seconds ago"
			} else {
				return "1 minute ago"
			}
		} else if intervalInMinutes >= 2 && intervalInMinutes <= 44 {
			return "\(Int(intervalInMinutes)) minutes ago"
		} else if intervalInMinutes >= 45 && intervalInMinutes <= 89 {
			return "about 1 hour ago"
		} else if intervalInMinutes >= 90 && intervalInMinutes <= 1439 {
			return "\(Int(ceil(intervalInMinutes / 60.0))) hours ago"
		} else if intervalInMinutes >= 1440 && intervalInMinutes <= 2879 {
			return "1 day ago"
		} else if intervalInMinutes >= 2880 && intervalInMinutes <= 43199 {
			return "\(Int(ceil(intervalInMinutes / 1440.0))) days ago"
		} else if intervalInMinutes >= 43200 && intervalInMinutes <= 86399 {
			return "1 month ago"
		} else if intervalInMinutes >= 86400 && intervalInMinutes <= 525599 {
			return "\(Int(ceil(intervalInMinutes / 43200.0))) months ago"
		} else if intervalInMinutes >= 525600 && intervalInMinutes <= 1051199 {
			return "1 year ago"
		}

		return "\(Int(ceil(intervalInMinutes / 525600.0))) years ago"
	}

    /// Returns the amount of days from another date. If the amount of days is negative it will return -1
    func days(to date: Date) -> Int {
        if Calendar.current.dateComponents([.day], from: self as Date, to: date).day ?? -1 < 0 {
            return -1
        } else {
            return Calendar.current.dateComponents([.day], from: self as Date, to: date).day ?? -1
        }

    }

    func weeks(to date: Date) -> Int {
       return days(to: date)/7
    }

    func minutes(fromDate date: NSDate) -> Int {
        return Calendar.current.dateComponents([.minute], from: date as Date, to: self as Date).minute!
    }

}
