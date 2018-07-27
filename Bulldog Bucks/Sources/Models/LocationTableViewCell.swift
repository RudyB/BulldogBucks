//
//  LocationTableViewCell.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 5/1/17.
//  Copyright © 2017 Rudy Bermudez. All rights reserved.
//

import UIKit

/// Models a TableViewCell that will be used by LocationResultsViewController to display locations
class LocationTableViewCell: UITableViewCell {

    /// Name of the location to display in the table view
    @IBOutlet weak var LocationTitleLabel: UILabel!

    /// Default initalization
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
