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
    let locationProvider: LocationProvider = YelpClient()
    
    let userLocationProvider: UserLocationProvider = UserLocationService()
    let user: User? = FirebaseAuthClient.getUser()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Life Cycle
    
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
        guard let userID = user?.uid else { return }
        Task {
            let locationID = await FirebaseManager.dbClient.getCurrentLocationID(userID: userID)
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedRow: Int = tableView.indexPathForSelectedRow?.row else { return }
        if let detailsVC = segue.destination as? DetailsViewController {
            let location: Location = locations[selectedRow]
            detailsVC.location = location
            detailsVC.delegate = self
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
