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
    
    var locations: [Location] = []
    let locationProvider: LocationProvider
    
    let userLocationProvider: UserLocationProvider
    let user: User
    
    @IBOutlet weak var tableView: UITableView!
    
    let coordinator: LocationsFlow?
    
    // MARK: - VC Life Cycle
    
    static func instantiate(user: User, locationProvider: LocationProvider = YelpClient(), userLocationProvider: UserLocationProvider = UserLocationService(), coordinator: LocationsFlow?) -> LocationsViewController {
        let locationsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LocationsViewController") { coder in
            LocationsViewController(coder: coder, user: user, locationProvider: locationProvider, userLocationProvider: userLocationProvider, coordinator: coordinator)
        }
        locationsVC.navigationItem.title = "Locations"
        return locationsVC
    }
    
    init?(coder: NSCoder, user: User, locationProvider: LocationProvider = YelpClient(), userLocationProvider: UserLocationProvider = UserLocationService(), coordinator: LocationsFlow?) {
        self.user = user
        self.locationProvider = locationProvider
        self.userLocationProvider = userLocationProvider
        self.coordinator = coordinator
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setCurrentLocationID()
        updateLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    // MARK: - Locations
    
    func setCurrentLocationID() {
        Task {
            let locationID = await FirebaseManager.dbClient.getCurrentLocationID(userID: user.uid)
            CurrentSession.locationID = locationID
        }
    }
    
    func updateLocations() {
        Task {
            do {
                let userLocation = try await userLocationProvider.findUserLocation()
                locations = try await self.locationProvider.retrieveLocations(near: userLocation)
                locations.sort(by: { $0.distance < $1.distance })
                tableView.reloadData()
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
}

// MARK: - Table View

extension LocationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationCell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationCell
        let location = locations[indexPath.row]
        locationCell.location = location
        return locationCell
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
        let selectedLocation = locations[indexPath.row]
        coordinator?.coordinateToDetail(location: selectedLocation, delegate: self)
    }
}

extension LocationsViewController: DetailsViewControllerDelegate {
    func didChangeLocation(fromID: String?, toID: String?) {
        guard let cells = tableView.visibleCells as? [LocationCell] else { return }
        for cell in cells {
            guard let id = cell.location?.id else { continue }
            if id == fromID {
                cell.isHereIndicator.isHidden = true
            }
            else if id == toID {
                cell.isHereIndicator.isHidden = false
            }
        }
    }
}
