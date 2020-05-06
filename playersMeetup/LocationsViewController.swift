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

var locations = [[String:Any]]()
class LocationsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var long: Double = 0.0
    var lat: Double = 0.0
    static let shared = LocationsViewController()
    //    static let ref = Database.database().reference().ref.child("businesses")
    static var selectedId: String = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let loc = locations[indexPath.row]
        cell.locationLabel.text = loc["name"] as? String
        let strURL = loc["image_url"] as! String
        if let url = URL(string: strURL){
            cell.locationImageView.af.setImage(withURL: url)
        }
        cell.distanceLabel.text = String(format: "%f", loc["distance"] as! Double)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! LocationTableViewCell
        let selectedLocation = locations[indexPath.row]
        ///     print("selected:")
        ///        print(cell.locationLabel.text)
        LocationsViewController.selectedId = selectedLocation["id"] as! String
        ///        print(selectedLocation["name"])
        ///  print("done selected")kti
    }
    
    @IBOutlet weak var tableView: UITableView!
    let service = MoyaProvider<YelpService.BusinessesProvider>()
    let jsonDecoder = JSONDecoder()
    var names: [String: Int] = [:]
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
            //change color of bar title
       let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        print("view did load \(LocationsViewController.shared.count)")
        
        //        overrideUserInterfaceStyle = .light
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways{
            guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else { print("here")
                tableView.dataSource = self
                tableView.delegate = self
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase ///letting it know camel case
                service.request(.search(lat: 37.4419, long: -122.1430)) { (result) in switch result {
                case .success(let response):
                    let dataDictionary = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                    locations = dataDictionary["businesses"] as! [[String:Any]]
                    for loc in locations{
                        if self.names[loc["id"] as! String] != nil {
                            print("dont do anything")
                        }
                        else{
                            print("assign 0")
                            self.names[loc["id"] as! String] = 0
                        }
                    }
                    for (name,count) in self.names{
                        FirebaseReferences.businessesRef.observeSingleEvent(of: .value) { (snapshot) in
                            if snapshot.hasChild(name){
                                print("exists \(name)")
                            }
                            else{
                                print("doesnt exist")
                                //if doesnt exist add it as child to businesses
                                let newLoc = FirebaseReferences.businessesRef.child(name)
                                newLoc.setValue(count)
                            }
                        }
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                    }
                }
                return
            }
            tableView.dataSource = self
            tableView.delegate = self
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase ///letting it know camel case
            service.request(.search(lat: locValue.latitude, long: locValue.longitude)) { (result) in switch result {
            case .success(let response):
                let dataDictionary = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                locations = dataDictionary["businesses"] as! [[String:Any]]
                for loc in locations{
                    if self.names[loc["id"] as! String] != nil {
                        print("dont do anything")
                    }
                    else{
                        print("assign 0")
                        self.names[loc["id"] as! String] = 0
                    }
                }
                //                    make counter var - update counter on click and set ref
                //                   FirebaseReferences.businessesRef.setValue(self.names)
                for (name,count) in self.names{
                    FirebaseReferences.businessesRef.observeSingleEvent(of: .value) { (snapshot) in
                        if snapshot.hasChild(name){
                            print("exists \(name)")
                        }
                        else{
                            print("doesnt exist")
                            //if doesnt exist add it as child to businesses
                            let newLoc = FirebaseReferences.businessesRef.child(name)
                            newLoc.setValue(count)
                        }
                    }
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Error: \(error)")
                }
            }
        }
    }
}
