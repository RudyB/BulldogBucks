//
//  CollectionViewCell.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 9/4/17.
//
//

import UIKit

class SwipesCollectionViewCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "SwipesCollectionViewCell"
    
    @IBOutlet weak var amountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
