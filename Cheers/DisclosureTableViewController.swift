//
//  DisclosureTableViewController.swift
//  Cheers
//
//  Created by Riley Steele Parsons on 10/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

import UIKit

class DisclosureTableViewController: UITableViewController {

    weak var delegate : DataEntryViewController?
    var listArray : [String] = []
    var selectedElements : [String] = []
    var allowMultipleSelections:Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let element = listArray[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = element
        cell.selectionStyle = .none
        
        if (selectedElements.contains(element)){
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!allowMultipleSelections){
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedElements = [listArray[(indexPath as NSIndexPath).row]]
        } else {
            if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark){
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                selectedElements.remove(at: selectedElements.index(of: listArray[(indexPath as NSIndexPath).row])!)
            } else {
                selectedElements.append(listArray[(indexPath as NSIndexPath).row])
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (!allowMultipleSelections){
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            selectedElements.remove(at: selectedElements.index(of: listArray[(indexPath as NSIndexPath).row])!)
        }
    }

    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        delegate?.finishedSelectingElements(self, selectedElements: selectedElements)
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

protocol DisclosureTableViewControllerDelegate: class {
    func finishedSelectingElements(_ sender: DisclosureTableViewController, selectedElements:[String])
}
