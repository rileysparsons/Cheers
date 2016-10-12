//
//  RatingTableViewCell.swift
//  
//
//  Created by Riley Steele Parsons on 10/7/16.
//
//

import UIKit
import HCSStarRatingView

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingView: HCSStarRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
