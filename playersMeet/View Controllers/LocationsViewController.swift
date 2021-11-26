//
//  LocationsViewController.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import Moya
import AlamofireImage
import Firebase

class LocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    static let shared = LocationsViewController()
    var locations: [Location] = []
    let locationProvider: LocationProvider = YelpClient()
    let userLocationProvider: UserLocationProvider = UserLocationService()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let location = locations[indexPath.row]
        let user: User? = Auth.auth().currentUser
        cell.locationLabel.text = location.name
        cell.locationImageView.af.setImage(withURL: location.imageUrl)
        let dist = String(format: "%.3f", location.distance/1609.344)
        cell.distanceLabel.text = "\(dist) mi"
        // is here indication on - off
        FirebaseDBClient.userInfoRef.child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value as? [String])?[0] == "joined" && (snapshot.value as? [String])?[1] == location.id {
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
    
    @IBOutlet weak var tableView: UITableView!
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
        updateLocations()
    }
    
    // MARK: - Locations
    
    func updateLocations() {
        userLocationProvider.findUserLocation { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let userLocation):
                self.locationProvider.retrieveLocations(near: userLocation, completion: self.loadLocations(result:))
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    func loadLocations(result: Result<[Location], Error>) {
        switch result {
        case .success(let locations):
            self.locations = locations
            self.tableView.reloadData()
        case .failure(let error):
            self.showErrorAlert(with: error)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedRow: Int = tableView.indexPathForSelectedRow?.row else { return }
        if let detailsVC = segue.destination as? DetailsViewController {
            let location: Location = locations[selectedRow]
            detailsVC.location = location
        }
    }
}
