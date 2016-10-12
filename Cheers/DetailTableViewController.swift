//
//  DetailTableViewController.swift
//  Cheers
//
//  Created by Riley Steele Parsons on 10/9/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

import UIKit
import CoreData

class DetailTableViewController: UITableViewController {

    var coffee : NSManagedObject? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Display image as header in table
        let imageView = UIImageView(image: UIImage(data: (coffee?.value(forKey: "imageData")) as! Data))
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 200)
        imageView.contentMode = .scaleAspectFill
        tableView.tableHeaderView = imageView
        
        title = coffee?.value(forKey: "type") as? String
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0){
            return 2
        } else if (section == 1){
            let tastingNotes = coffee?.value(forKey: "tastingNotes") as! [String]
            return tastingNotes.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1){
            return "Tasting Notes"
        }
        return nil
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if ((indexPath as NSIndexPath).section == 0){
            switch (indexPath as NSIndexPath).row {
            case 0:
                let rating = coffee?.value(forKey: "rating") as! Int
                cell.textLabel?.text = "Rating: " + rating.description + "/5"
            case 1:
                if let location = coffee?.value(forKey: "locationName"){
                    cell.textLabel?.text = "Location: " + (location as! String)
                }
            default:
                break
                
            }
        } else if ((indexPath as NSIndexPath).section == 1){
            let tastingNotes = coffee?.value(forKey: "tastingNotes") as! [String]
            cell.textLabel?.text = tastingNotes[(indexPath as NSIndexPath).row]
        }
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
