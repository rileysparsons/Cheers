//
//  CoffeeTableViewCell.swift
//  Cheers
//
//  Created by Riley Steele Parsons on 10/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

class CoffeeTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var coffeeImageView: UIImageView!
    
    /** Number formatter for rating. */
    let numberFormatter = NumberFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        coffeeImageView?.layer.cornerRadius = 5
        coffeeImageView?.layer.masksToBounds = true
        ratingLabel?.layer.cornerRadius = 5
        ratingLabel?.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateView(forCoffee coffee:NSManagedObject){
        let rating = coffee.value(forKey: "rating") as! Float
        let ratingString = numberFormatter.string(from: NSNumber(value: rating))
        ratingLabel.text = ratingString
        
        ratingLabel.backgroundColor = UIColor.init(ciColor: backgroundColor(forRating: rating))
        
        emojiLabel.text = emoji(forRating: rating)
        
        titleLabel.text = coffee.value(forKey: "type") as? String
        
        locationLabel.text = coffee.value(forKey: "locationName") as? String
        
        descriptionLabel.text = formatDescription(withTags: coffee.value(forKey: "tastingNotes") as! [String])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let date = coffee.value(forKey: "date") as! Date
        
        
        dateLabel.text = dateFormatter.string(from: date)
        
        
        let image = UIImage(data:coffee.value(forKey: "thumbnailData") as! Data)
        coffeeImageView.image = image
    }
    
    func formatDescription(withTags tags:[String]) -> String{
        if (tags.count == 1){
            return "\"\(tags.first!.lowercased())\"."
        } else if tags.count == 0{
            return "No tasting notes"
        } else {
            var description:String = "\""
            for tag in tags {
                if (tags.index(of: tag)!+1 != tags.count){
                    description = description + (tag.lowercased() + ", ")
                } else {
                    description = description + ("and " + tag.lowercased() + "\"")
                }
            }
            return description
        }
    }
    
    func emoji(forRating rating: Float) -> String{
        let ratingInt = Int(rating)
        switch ratingInt {
        case 0:
            return "\u{1f4a9}"
        case 1:
            return "\u{1f626}"
        case 2:
            return "\u{1f60f}"
        case 3:
            return "\u{1f610}"
        case 4:
            return "\u{1f63a}"
        case 5:
            return "\u{02764}"
            
        default:
            break
        }
        return ""
    }
    
    func backgroundColor(forRating rating:Float) -> CIColor{
        let greenColor = CIColor(red: 78/255, green: 220/255, blue: 0/255)
        let yellowColor = CIColor(red: 255/255, green: 130/255, blue: 60/255)
        
        let ratingInt = Int(rating)
        
        var percentage: CGFloat = 0.0
        
        switch ratingInt {
        case 0:
            percentage = 1.0
        case 1:
            percentage = 0.8
        case 2:
           percentage = 0.6
        case 3:
          percentage = 0.4
        case 4:
            percentage = 0.2
        case 5:
            percentage = 0.0
            
        default:
            break
        }
        let resultRed = (greenColor.red + percentage * (yellowColor.red - greenColor.red))
        let resultGreen = (greenColor.green + percentage * (yellowColor.green - greenColor.green))
        let resultBlue = (greenColor.blue + percentage * (yellowColor.blue - greenColor.blue))
        return CIColor.init(red: resultRed, green: resultGreen, blue: resultBlue)
        
        
    }

}

