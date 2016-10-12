//
//  DataEntryViewController.swift
//  Cheers
//
//  Created by Riley Steele Parsons on 10/5/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

import UIKit
import CoreData
import HCSStarRatingView

class DataEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, DisclosureTableViewControllerDelegate, LocationTableViewControllerDelegate {


    @IBOutlet weak var tableView: UITableView!

    // ImagePickerController is presented immediately
    let imagePickerController = UIImagePickerController()
    
    // AppDelegate Singleton
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Options provided to user
    let coffeeTypes = ["Latte", "Cappuccino", "Flat White", "Drip"]
    let coffeeTags = ["Acidic", "Bright", "Dark", "Strong", "Bold", "Weak", "Burnt", "Floral", "Chocolate"]
    
    // User defined variables for drink
    var selectedCoffeeType:String = "None"
    var coffeeRating:CGFloat = 0
    var selectedCoffeeTags : [String] = []
    var coffeeImage:UIImage?
    var coffeeLocation:[String:AnyObject]?
    
    // Titles of DisclosureTableViewControllers that are used as identifiers in delegate methods
    let addCoffeeTastingNotesTitle = "Add Tasting Notes"
    let selectTypeTitle = "Select Type"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional setup
        
        // Places title of ViewController on Navigation Item in UI
        self.title = "New Coffee Entry"
        
        // Assigning the tableView outlet's delegate and datasource to self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Holding space for photo selected by the user
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 200))
        
        // Assigning self as delegate for the imagePickerController that is immediately presented
        imagePickerController.delegate = self
        
        // Assigning the correct source for the imagePickerController
        // FIXME: PhotoLibrary is set for testing on simulator only. Switch to Camera for deployment to device
        imagePickerController.sourceType = .photoLibrary
    
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:  "Cell")
        
        // Registers a custom nib as a cell for use in table view. Custom cell allows users to assign a rating to their drinks
        tableView.register(UINib(nibName:"RatingTableViewCell", bundle: nil), forCellReuseIdentifier:"RatingTableViewCell")
        
        // Presents the imagePickerController
        self.presentImagePicker()
    }

    
    
    @IBAction func barButtonTouched(_ sender: AnyObject) {
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Coffee", in: managedObjectContext)
        let coffee = NSManagedObject(entity: entityDescription!, insertInto: managedObjectContext)
        
        if (coffeeImage != nil){
            let coffeeImageData = UIImageJPEGRepresentation(coffeeImage!, 0.5)
            
            UIGraphicsBeginImageContext(CGSize(width: 50.0, height: 50.0))
            coffeeImage!.draw(in: CGRect(x: 0,y: 0,width: 50.0, height: 50.0))
            let coffeeImageThumbnail = UIGraphicsGetImageFromCurrentImageContext();
            let coffeeThumbnailData = UIImageJPEGRepresentation(coffeeImageThumbnail!, 0.5)
            UIGraphicsEndImageContext();
            
            coffee.setValue(coffeeThumbnailData, forKey: "thumbnailData")
            coffee.setValue(coffeeImageData, forKey: "imageData")
        }
        
        coffee.setValue(selectedCoffeeType, forKey: "type")
        coffee.setValue(Float(coffeeRating), forKey: "rating")
        coffee.setValue(selectedCoffeeTags, forKey: "tastingNotes")
        coffee.setValue(coffeeLocation?["venue"]!["name"]!, forKeyPath: "locationName")
        coffee.setValue(coffeeLocation?["venue"]!["id"]!, forKeyPath: "locationId")
        coffee.setValue(coffeeLocation?["venue"]!["lat"]!, forKeyPath: "locationLat")
        coffee.setValue(coffeeLocation?["venue"]!["long"]!, forKeyPath: "locationLong")
        coffee.setValue(Date(), forKeyPath: "date")
        
        do {
            try managedObjectContext.save()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let error as NSError {
            print("save failed: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if ((indexPath as NSIndexPath).section == 0){
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
                // The first row will display a picker for coffee types
                cell.textLabel?.text = "Coffee Type"
                cell.detailTextLabel?.text = selectedCoffeeType
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
                (cell as! RatingTableViewCell).ratingView.addTarget(self, action:#selector(DataEntryViewController.didChangeValue(_:)), for: .valueChanged)
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
                cell.textLabel?.text = "Coffee Shop"
                if let coffeeShopName = coffeeLocation?["venue"]!["name"]{
                    cell.detailTextLabel?.text = coffeeShopName as? String
                }

            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
                // The first row will display a picker for coffee types
                cell.textLabel?.text = "Tasting Notes"
                if (selectedCoffeeTags.count == 0){
                    cell.detailTextLabel?.text = "None"
                } else {
                    cell.detailTextLabel?.text = "\(selectedCoffeeTags.count) Tags"
                }
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).section == 0){
            
            let disclosureTableViewController = DisclosureTableViewController()
            disclosureTableViewController.delegate = self
            
            switch (indexPath as NSIndexPath).row {
            case 0:
                disclosureTableViewController.listArray = coffeeTypes
                disclosureTableViewController.selectedElements = [selectedCoffeeType]
                disclosureTableViewController.title = selectTypeTitle
                disclosureTableViewController.allowMultipleSelections = false
                self.navigationController?.pushViewController(disclosureTableViewController, animated: true)
            case 1:
                break
            case 2:
                let locationTableViewController = LocationTableViewController()
                locationTableViewController.delegate = self
                self.navigationController?.pushViewController(locationTableViewController, animated: true)
            case 3:
                disclosureTableViewController.listArray = coffeeTags
                disclosureTableViewController.selectedElements = selectedCoffeeTags
                disclosureTableViewController.title = addCoffeeTastingNotesTitle
                disclosureTableViewController.allowMultipleSelections = true
                self.navigationController?.pushViewController(disclosureTableViewController, animated: true)
            default:
                break
            }
            
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func presentImagePicker() {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            self.navigationController!.present(imagePickerController, animated: true, completion: nil)
        } else {
            let noCameraAlertController = UIAlertController(title: "No Camera Found", message: "A photo is required to document the drink", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
                
            })
            noCameraAlertController.addAction(cancelAction)
            self.present(noCameraAlertController, animated: true, completion: nil)
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Save image to global variable for later
        coffeeImage = image
        
        // Display image as header in table
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 200)
        imageView.contentMode = .scaleAspectFill
        tableView.tableHeaderView = imageView
        picker.dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coffeeTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCoffeeType = coffeeTypes[row]
        print(selectedCoffeeType)
    }
    
    func didChangeValue(_ sender: HCSStarRatingView){
        coffeeRating = sender.value
    }
    
    func finishedSelectingElements(_ sender: DisclosureTableViewController, selectedElements:[String]){
        if (selectedElements.count > 0){
            if (sender.title == addCoffeeTastingNotesTitle) {
                selectedCoffeeTags = selectedElements
            } else if (sender.title == selectTypeTitle){
                selectedCoffeeType = selectedElements.first!
            }
            tableView.reloadData()
        }
    }
    
    func venueWasSelected(_ sender:LocationTableViewController, venue:[String:AnyObject]){
        coffeeLocation = venue
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
