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
    
    var selectedLocation : JSONParameters?
    var selectedCellIndexPath : IndexPath?
    
    
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
        if venueItems != nil {
            return venueItems!.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "venueCell")
        let item = self.venueItems![(indexPath as NSIndexPath).row] as JSONParameters!
        self.configureCellWithItem(cell, item: item!, indexPath: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            self.delegate.venueWasDeselected(self, venue: selectedLocation!)
            selectedLocation = nil
            selectedCellIndexPath = nil
        } else {
            if (selectedLocation != nil){
                tableView.cellForRow(at: selectedCellIndexPath!)?.accessoryType = .none
            }
            selectedCellIndexPath = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedLocation = venueItems![(indexPath as NSIndexPath).row]
            self.delegate.venueWasSelected(self, venue: selectedLocation!)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
 
    func configureCellWithItem(_ cell:UITableViewCell, item: JSONParameters, indexPath: IndexPath) {
        
            cell.textLabel?.text = item["name"] as? String
            if let distanceMeters = item["location"]!["distance"] as? CGFloat {
                cell.detailTextLabel?.text = stringDistance(fromMeters: distanceMeters)
            }
        
            if selectedLocation != nil {
               if selectedLocation?["id"] as! String == item["id"] as! String{
                    cell.accessoryType = .checkmark
                    selectedCellIndexPath = indexPath
                }
        }
    }
    
    
    func exploreVenues() {
        guard let location = self.locationManager.location else {
            return
        }
        
        let parameters = location.parameters()
        
        let task = self.session.venues.search(parameters) {
            (result) -> Void in
            if self.venueItems != nil {
                return
            }
            if !Thread.isMainThread {
                fatalError("!!!")
            }
            
            if let response = result.response {
                self.venueItems = response["venues"] as? [JSONParameters]
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
        if locations.first != nil {
            if self.venueItems == nil {
                exploreVenues()
            }
//            self.resultsTableViewController.location = newLocation
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func stringDistance(fromMeters distanceInMeters:CGFloat) -> String{
        let useMetricSystem = NSLocale.current.usesMetricSystem
        var localDistance:CGFloat
        var localDistanceUnit:String
        
        
        if useMetricSystem {
            localDistance = distanceInMeters/1000 // Conversion to km
            localDistanceUnit = "km"
            if localDistance < 1.0 {
                localDistance *= 1000
                localDistance = round(localDistance/100.0)*100.0
                localDistanceUnit = "m"
                return String(format: "%f", localDistance) + " " + localDistanceUnit
            }
        } else {
            localDistance = distanceInMeters/1609.34 // Conversion to miles
            localDistanceUnit = "mi"
            if localDistance < 0.3 {
                localDistance *= 5280
                localDistance = round(localDistance/100.0)*100.0
                localDistanceUnit = "ft"
                return String(format: "%.f", localDistance) + " " + localDistanceUnit
            }
        }
        
        return String(format: "%.1f", localDistance) + " " + localDistanceUnit
    }
}


extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let categoryId = "4bf58dd8d48988d1e0931735"
        let radius = "1000"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc,
            Parameter.categoryId:categoryId,
            Parameter.radius : radius
        ]
        return parameters
    }
}

protocol LocationTableViewControllerDelegate {
    func venueWasSelected(_ sender:LocationTableViewController, venue:[String:AnyObject])
    func venueWasDeselected(_ sender:LocationTableViewController, venue:[String:AnyObject])
}
