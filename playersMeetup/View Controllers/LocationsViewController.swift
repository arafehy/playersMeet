//
//  LocationsViewController.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Moya
import AlamofireImage
import Firebase
import CoreLocation

var locations = [[String: Any]]()
class LocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var long: Double = 0.0
    var lat: Double = 0.0
    
    static let shared = LocationsViewController()
    
    static var selectedId: String = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let loc = locations[indexPath.row]
        let user: User? = Auth.auth().currentUser
        cell.locationLabel.text = loc["name"] as? String
        let strURL = loc["image_url"] as! String
        if let url = URL(string: strURL) {
            cell.locationImageView.af.setImage(withURL: url)
        }
        let dist = String(format: "%.3f", (loc["distance"] as! Double)/1609.344)
        cell.distanceLabel.text = "\(dist) mi"
        // is here indication on - off
        let selectedLocation = locations[indexPath.row]
        ///     print("selected:")
        ///        print(cell.locationLabel.text)
        let sel = selectedLocation["id"] as! String
        FirebaseDBClient.userInfoRef.child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value as? [String])?[0] == "joined" && (snapshot.value as? [String])?[1] == sel {
                cell.isHereIndicator.isHidden = false
            } else {
                cell.isHereIndicator.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 1.0) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.5
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = self.tableView.cellForRow(at: indexPath) as! LocationTableViewCell
        let selectedLocation = locations[indexPath.row]
        ///     print("selected:")
        ///        print(cell.locationLabel.text)
        LocationsViewController.selectedId = selectedLocation["id"] as! String
        ///        print(selectedLocation["name"])
        ///  print("done selected")kti
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    let service = MoyaProvider<YelpService.BusinessesProvider>()
    var names: [String: Int] = [:]
    var count = 0
    // reload table view to update indicator of joined location
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
    }
    //    override func viewDidAppear(_ animated: Bool) {
    //        tableView.reloadData()
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print("view did load \(LocationsViewController.shared.count)")
        
        //        overrideUserInterfaceStyle = .light
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        fetchLocations()
    }
    
    func fetchLocations() {
        let coordinates: CLLocationCoordinate2D = LocationManager.shared.getCoordinates()
        service.request(.search(coordinates.latitude, coordinates.longitude)) {
            [unowned self]
            (result) in
            switch result {
            case .success(let response):
                self.decodeYelpResponse(response)
                FirebaseManager.dbClient.addNewLocations(locations: self.names)
                self.tableView.reloadData()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func decodeYelpResponse(_ response: Response) {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase // letting it know camel case
        do {
            let dataDictionary = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
            locations = dataDictionary["businesses"] as? [[String: Any]] ?? [[:]]
            for location in locations {
                guard let locationID = location["id"] as? String else { continue }
                if self.names[locationID] == nil {
                    self.names[locationID] = 0
                }
            }
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! LocationTableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let location = locations[indexPath!.row]
        
        let detailsVC = segue.destination as! DetailsViewController
        detailsVC.location = location
    }
}
