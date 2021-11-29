//
//  DetailsViewController.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps

class DetailsViewController: UIViewController {
    @IBOutlet weak var leaveTeamButton: UIButton!
    @IBOutlet weak var joinTeamButton: UIButton!
    @IBOutlet weak var youInTeamLabel: UILabel!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var playerCountLabel: UILabel!
    
    var location: Location!
    var playerCount: Int = 0 {
        didSet {
            print("Set new player count from \(oldValue) to \(playerCount)")
            setPlayerCountLabel()
        }
    }
    let user: User? = FirebaseAuthClient.getUser()
    var isAtLocation: Bool {
        location.id == CurrentSession.currentLocationID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinTeamButton.rounded()
        leaveTeamButton.rounded()
        chatButton.rounded()
        
        navigationItem.title = location.name
        
        updateCurrentLocationStatus()
        startPlayerCountObserver()
        
        //check if user is already in team selected
        guard let userID = user?.uid else { return }
        FirebaseDBClient.userInfoRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value as? [String])?[0] == "joined" && self.location.id == (snapshot.value as? [String])?[1] {
                print("Already in that team")
                //dont allow to join
                self.joinTeamButton.isEnabled = false
                self.leaveTeamButton.isEnabled = true
                self.youInTeamLabel.text = "You are in this team"
                self.chatButton.isEnabled = true
            } else {
                self.youInTeamLabel.text = ""
            }
        }
        /// increment value in database
        
        ///make first value stay the same until end game
        
        
        
        for loc in locations{
            if loc["id"] as! String == LocationsViewController.selectedId{
                let coord = loc["coordinates"] as! NSDictionary
                print(coord)
                let lat = coord.value(forKey: "latitude")!
                let long = coord.value(forKey: "longitude")!
                latSelected = "\(lat)"
                longSelected = "\(long)"


            }
        }
        let latDouble: Double = (latSelected as NSString).doubleValue
        let longDouble: Double = (longSelected as NSString).doubleValue
        let camera = GMSCameraPosition.camera(withLatitude: latDouble, longitude: longDouble, zoom: 14)
        googleMapView.camera = camera
        googleMapView.animate(to: camera)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble)
        marker.map = googleMapView
        //        let gesture = UITapGestureRecognizer(target: self, action: Selector(("MapsPressed")))
        //        googleMapView.addGestureRecognizer(gesture)

        googleMapView.delegate = self
        
    }
    
    func startPlayerCountObserver() {
        FirebaseManager.dbClient.observePlayerCount(at: location.id) { playerCount in
            // Listen in realtime to whenever it updates
            guard let playerCount = playerCount else {
                print("Player count for location with ID \(self.location.id) unavailable")
                return
            }
            self.playerCount = playerCount
            LocationsViewController.shared.count = playerCount
        }
    }
    
    func updateCurrentLocationStatus() {
        guard let userID = user?.uid else { return }
        FirebaseManager.dbClient.getCurrentLocationID(userID: userID) { [weak self] (locationID) in
            guard let locationID = locationID, locationID == CurrentSession.currentLocationID else {
                return
            }
            self?.setButtonsAndLabels()
        }
    }
    
    @IBAction func leaveTeamAction(_ sender: Any) {
        guard let userID = user?.uid else { return }
        FirebaseManager.dbClient.leaveLocationWith(ID: location.id, for: userID) { hasLeft in
            guard hasLeft else { return }
            CurrentSession.currentLocationID = nil
        }
    }
    
    @IBAction func joinTeamAction(_ sender: Any) {
        guard let userID = user?.uid else { return }
        
        guard CurrentSession.currentLocationID == nil else {
            showSwitchTeamAlert()
            return
        }
        
        FirebaseManager.dbClient.joinLocationWith(ID: location.id, for: userID) { hasJoined in
            guard hasJoined else { return }
            CurrentSession.currentLocationID = self.location.id
            self.setButtonsAndLabels()
        }
    }
    
    func switchLocation(alert: UIAlertAction) {
        guard let userID = user?.uid, let currentLocationID = CurrentSession.currentLocationID else { return }
        FirebaseManager.dbClient.switchLocation(for: userID, from: currentLocationID, to: location.id) { hasSwitched in
            guard hasSwitched else { return }
            CurrentSession.currentLocationID = self.location.id
            self.setButtonsAndLabels()
        }
    }
    
    // MARK: - Views
    
    func setPlayerCountLabel() {
        switch playerCount {
        case 0:
            playerCountLabel.text = "No players are here."
        case 1:
            playerCountLabel.text = "1 player is here."
        case 2...:
            playerCountLabel.text = "\(playerCount) players are here."
        default:
            playerCountLabel.text = "Can't fetch player count"
        }
    }
    
    func setButtonsAndLabels() {
        if isAtLocation {
            joinTeamButton.isEnabled = false
            leaveTeamButton.isEnabled = true
            chatButton.isEnabled = true
            youInTeamLabel.text = "You are in this team"
        } else {
            joinTeamButton.isEnabled = true
            leaveTeamButton.isEnabled = false
            chatButton.isEnabled = false
            youInTeamLabel.text = ""
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {
            let chatVC = segue.destination as! TeamChatViewController
            chatVC.teamID = location.id
        }
    }
}

// MARK: - Map

extension DetailsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard let URLNavigation = URL(string: "comgooglemaps://"),
              UIApplication.shared.canOpenURL(URLNavigation),
              let URLDestination = URL(string: "comgooglemaps://?saddr=&daddr=\(location.coordinates.latitude),\(location.coordinates.longitude)&directionsmode=driving") else {
                  NSLog("Can't use comgooglemaps://")
                  self.openTrackerInBrowser()
                  return
              }
        UIApplication.shared.open(URLDestination)
    }
    
    func openTrackerInBrowser() {
        if let URLDestination = URL(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(location.coordinates.latitude),\(location.coordinates.longitude)&directionsmode=driving") {
            UIApplication.shared.open(URLDestination)
        }
    }
}
