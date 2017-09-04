//
//  CollectionViewCell.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 9/4/17.
//
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "DetailCollectionViewCell"
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
