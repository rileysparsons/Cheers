//
//  LocationTableViewController.swift
//  
//
//  Created by Riley Steele Parsons on 10/10/16.
//
//

import UIKit
import CoreLocation
import QuadratTouch


class LocationTableViewController: UITableViewController, CLLocationManagerDelegate {

    // To simplify the retrieval of venues from the Foursquare API (via Quadrat Touch)
    typealias JSONParameters = [String:AnyObject]
    
    // We need to create a delegate in order to pass information back to the presenting ViewController
    var delegate:DataEntryViewController!
    
    var searchController: UISearchController!
    //var resultsTableViewController: SearchTableViewController!
    
    // Quadrat Touch variables
    var session : Session!
    
    
    
    var locationManager : CLLocationManager!
    var venueItems : [JSONParameters]?
    
    /** Number formatter for rating. */
    let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "venueCell")
        
        self.session = Session.sharedSession()
        self.session.logger = ConsoleLogger()
        
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.authorizedWhenInUse
            || status == CLAuthorizationStatus.authorizedAlways {
            self.locationManager.startUpdatingLocation()
        } else {
            showNoPermissionsAlert()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let venueItems = self.venueItems {
            return venueItems.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "venueCell", for: indexPath)
        let item = self.venueItems![(indexPath as NSIndexPath).row] as JSONParameters!
        self.configureCellWithItem(cell, item: item!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.venueWasSelected(self, venue: venueItems![(indexPath as NSIndexPath).row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
 
    func configureCellWithItem(_ cell:UITableViewCell, item: JSONParameters) {
        if let venueInfo = item["venue"] as? JSONParameters {
            cell.textLabel?.text = venueInfo["name"] as? String
            if let rating = venueInfo["rating"] as? CGFloat {
                let number = NSNumber(value: Float(rating) as Float as Float)
                cell.detailTextLabel?.text = numberFormatter.string(from: number)
            }
        }
    }
    
    
    func exploreVenues() {
        guard let location = self.locationManager.location else {
            return
        }
        
        let parameters = location.parameters()
        let task = self.session.venues.explore(parameters) {
            (result) -> Void in
            if self.venueItems != nil {
                return
            }
            if !Thread.isMainThread {
                fatalError("!!!")
            }
            
            if let response = result.response {
                if let groups = response["groups"] as? [[String: AnyObject]]  {
                    var venues = [[String: AnyObject]]()
                    for group in groups {
                        if let items = group["items"] as? [[String: AnyObject]] {
                            venues += items
                        }
                    }
                    
                    self.venueItems = venues
                }
                self.tableView.reloadData()
            } else if result.error != nil || !result.isCancelled() {
//                self.showErrorAlert(result.error)
            }
        }
        task.start()
    }

    
    func showNoPermissionsAlert() {
        let alertController = UIAlertController(title: "No permission",
                                                message: "In order to work, app needs your location", preferredStyle: .alert)
        let openSettings = UIAlertAction(title: "Open settings", style: .default, handler: {
            (action) -> Void in
            let URL = Foundation.URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(URL!)
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(openSettings)
        self.present(alertController, animated: true, completion: nil)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted  {
            showNoPermissionsAlert()
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            if self.venueItems == nil {
                exploreVenues()
            }
//            self.resultsTableViewController.location = newLocation
            self.locationManager.stopUpdatingLocation()
        }
    }
}


extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}

protocol LocationTableViewControllerDelegate {
    func venueWasSelected(_ sender:LocationTableViewController, venue:[String:AnyObject])
}
