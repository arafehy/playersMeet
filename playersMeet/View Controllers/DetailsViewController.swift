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
        setButtonsAndLabels()
        
        startPlayerCountObserver()
        
        initializeMap()
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
    
    @IBAction func leaveTeamAction(_ sender: Any) {
        guard let userID = user?.uid else { return }
        FirebaseManager.dbClient.leaveLocationWith(ID: location.id, for: userID) { hasLeft in
            guard hasLeft else { return }
            CurrentSession.currentLocationID = nil
            self.setButtonsAndLabels()
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
    func initializeMap() {
        googleMapView.delegate = self
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 14)
        googleMapView.camera = camera
        googleMapView.animate(to: camera)
        let marker = GMSMarker(position: coordinates)
        marker.map = googleMapView
    }
    
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
