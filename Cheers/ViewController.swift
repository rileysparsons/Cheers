//
//  ViewController.swift
//  Cheers
//
//  Created by Riley Steele Parsons on 10/5/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var drinks = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Coffee History"
        self.tableView!.register(UINib(nibName:"CoffeeTableViewCell", bundle: nil) , forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Coffee")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            drinks = results as! [NSManagedObject]
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! CoffeeTableViewCell
        let drink =  drinks[(indexPath as NSIndexPath).row]
        cell.updateView(forCoffee: drink)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        let detailTableViewController = DetailTableViewController()
        detailTableViewController.coffee = drinks[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(detailTableViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
}

