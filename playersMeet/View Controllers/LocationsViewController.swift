//
//  LocationsViewController.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import AlamofireImage
import Firebase

class LocationsViewController: UIViewController {
    
    // MARK: - Properties
    
    static let shared = LocationsViewController()
    
    var locations: [Location] = []
    let locationProvider: LocationProvider = YelpClient()
    
    let userLocationProvider: UserLocationProvider = UserLocationService()
    let user: User? = FirebaseAuthClient.getUser()
    
    var count = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print("view did load \(LocationsViewController.shared.count)")
        setCurrentLocationID()
        updateLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Locations
    
    func setCurrentLocationID() {
        guard let userID = user?.uid else { return }
        FirebaseManager.dbClient.getCurrentLocationID(userID: userID) { (locationID) in
            CurrentSession.currentLocationID = locationID
        }
    }
    
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

// MARK: - Table View

extension LocationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let location = locations[indexPath.row]
        cell.locationLabel.text = location.name
        cell.locationImageView.af.setImage(withURL: location.imageUrl, cacheKey: location.id)
        cell.distanceLabel.text = Formatter.getReadableString(measurement: location.distance)
        cell.isHereIndicator.isHidden = location.id != CurrentSession.currentLocationID
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
}
