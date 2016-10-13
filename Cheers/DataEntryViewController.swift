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

class DataEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DisclosureTableViewControllerDelegate, LocationTableViewControllerDelegate {


    @IBOutlet weak var tableView: UITableView!

    // ImagePickerController is presented immediately
    let imagePickerController = UIImagePickerController()
    
    // AppDelegate Singleton
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        
        let addPhotoButton = UIButton(type: .system)
        addPhotoButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
        addPhotoButton.setTitle("Add \u{1f4f8} of \u{2615}", for: .normal)
        addPhotoButton.setTitleColor(UIColor.black, for: .normal)
        addPhotoButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        tableView.tableHeaderView?.addSubview(addPhotoButton)
        addPhotoButton.bindFrameToSuperview()
        
        // Assigning self as delegate for the imagePickerController that is immediately presented
        imagePickerController.delegate = self
    
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:  "Cell")
        
        // Registers a custom nib as a cell for use in table view. Custom cell allows users to assign a rating to their drinks
        tableView.register(UINib(nibName:"RatingTableViewCell", bundle: nil), forCellReuseIdentifier:"RatingTableViewCell")
        
        // Presents the imagePickerController
        self.presentImagePicker()
    }

    
    
    @IBAction func doneBarButtonTouched(_ sender: AnyObject) {
        
        if checkFieldCompletion() {
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
            //#FIXME
            coffee.setValue(selectedCoffeeType, forKey: "type")
            coffee.setValue(Float(coffeeRating), forKey: "rating")
            coffee.setValue(selectedCoffeeTags, forKey: "tastingNotes")
            coffee.setValue(coffeeLocation?["name"]!, forKeyPath: "locationName")
            coffee.setValue(coffeeLocation?["id"]!, forKeyPath: "locationId")
            coffee.setValue(coffeeLocation?["location"]!["lat"]!, forKeyPath: "locationLat")
            coffee.setValue(coffeeLocation?["location"]!["lng"]!, forKeyPath: "locationLong")
            coffee.setValue(Date(), forKeyPath: "date")
            
            do {
                try managedObjectContext.save()
                _ = self.dismiss(animated: true, completion: nil)
            } catch let error as NSError {
                print("save failed: \(error)")
            }
        }

    }
    
    
    
    @IBAction func cancelBarButtonTouched(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        }
        return 0
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
                cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
                cell.textLabel?.text = "Coffee Shop"
                if let coffeeShopName = coffeeLocation?["name"]{
                    cell.detailTextLabel?.text = coffeeShopName as? String
                } else {
                    cell.detailTextLabel?.text = "None"
                }

            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
                (cell as! RatingTableViewCell).ratingView.addTarget(self, action:#selector(DataEntryViewController.didChangeValue(_:)), for: .valueChanged)
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
                // The first row will display a picker for coffee types
                cell.textLabel?.text = "Tasting Notes"
                if (selectedCoffeeTags.count == 0){
                    cell.detailTextLabel?.text = "None"
                } else {
                    cell.detailTextLabel?.text = "\(selectedCoffeeTags.count)"
                }
            default:
                break
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let disclosureTableViewController = DisclosureTableViewController()
        disclosureTableViewController.delegate = self
        if ((indexPath as NSIndexPath).section == 0){
            
            switch (indexPath as NSIndexPath).row {
            case 0:
                disclosureTableViewController.listArray = coffee.types
                disclosureTableViewController.selectedElements = [selectedCoffeeType]
                disclosureTableViewController.title = selectTypeTitle
                disclosureTableViewController.allowMultipleSelections = false
                self.navigationController?.pushViewController(disclosureTableViewController, animated: true)
            case 1:
                let locationTableViewController = LocationTableViewController()
                locationTableViewController.delegate = self
                locationTableViewController.selectedLocation = coffeeLocation
                self.navigationController?.pushViewController(locationTableViewController, animated: true)
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row{
            case 0:
                break
            case 1:
                disclosureTableViewController.listArray = coffee.characteristics
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
            
            // Assigning the correct source for the imagePickerController
            imagePickerController.sourceType = .photoLibrary
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            let noCameraAlertController = UIAlertController(title: "No Camera Found", message: "A photo is required to document the drink", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                _ = self.dismiss(animated: true, completion: nil)
                
            })
            noCameraAlertController.addAction(cancelAction)
            self.present(noCameraAlertController, animated: true, completion: nil)
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Save image to global variable for later
        coffeeImage = image
        
        // Display image as header in table
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 200))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        tableView.tableHeaderView = imageView
        picker.dismiss(animated: true, completion: nil)
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
    
    func venueWasDeselected(_ sender:LocationTableViewController, venue:[String:AnyObject]){
        coffeeLocation = nil
        tableView.reloadData()
    }
    
    // Data validation
    func checkFieldCompletion() -> Bool {
        
        if selectedCoffeeType == "None" || selectedCoffeeType ==  ""{
            return false
        }
        
        if selectedCoffeeTags.isEmpty {
            return false
        }
        
        if coffeeImage == nil {
            return false
        }
        
        if (coffeeLocation?.isEmpty)! {
            return false
        }
        
        return true
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

extension UIView {
    func bindFrameToSuperview(){
        guard let superview = self.superview else {
            print("Call .addSubview prior to bindFrameToSuperview")
            return
        }
        
        superview.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview":self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview":self]))
        
    }
}
