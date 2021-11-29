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
        leaveTeamButton.isEnabled = false
        joinTeamButton.isEnabled = true
        self.chatButton.isEnabled = false //not in team
        
        let referenceTeamCount = FirebaseDBClient.businessesRef.child(location.id)
        FirebaseDBClient.businessesRef.child(location.id).observeSingleEvent(of: .value) { (snapshot) in
            guard let playerCountBeforeLeaving = snapshot.value as? Int else { return }
            LocationsViewController.shared.count = playerCountBeforeLeaving - 1
            
            print("leaving this id: \(self.location.id)")
            print("after leaving count is \(LocationsViewController.shared.count)")
            referenceTeamCount.setValue(LocationsViewController.shared.count)
            
            let array: [String] = ["not joined","0"]
            guard let userID = self.user?.uid else { return }
            FirebaseDBClient.userInfoRef.child(userID).setValue(array)
            self.youInTeamLabel.text = ""
            
            CurrentSession.currentLocationID = nil
        }
    }
    
    @IBAction func joinTeamAction(_ sender: Any) {
        guard let userID = user?.uid else { return }
        FirebaseDBClient.userInfoRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value as? [String])?[0] == "not joined"
            {
                self.joinTeamButton.isEnabled = false
                self.leaveTeamButton.isEnabled = true
                self.playerCount += 1
                LocationsViewController.shared.count += 1
                //businesses count modification
                let referenceTeamCount = FirebaseDBClient.businessesRef.child(self.location.id)
                referenceTeamCount.setValue(LocationsViewController.shared.count)
                //userInfo modification
                let array: [String] = ["joined", self.location.id]
                FirebaseDBClient.userInfoRef.child(userID).setValue(array)
                self.youInTeamLabel.text = "You are in this team"
                self.chatButton.isEnabled = true
            }
            else {
                self.joinTeamButton.isEnabled = true
                self.leaveTeamButton.isEnabled = false
                self.chatButton.isEnabled = false //not in team
                self.showSwitchTeamAlert()
            }
        }
    }
    
    func changeLocation(alert: UIAlertAction) {
        // get id of loctaion of the user now then find it in businesses and decrement count
        // ref here is for userInfo
        youInTeamLabel.text = "You are now in this team"
        chatButton.isEnabled = true
        guard let userID = user?.uid else { return }
        FirebaseDBClient.userInfoRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            // get location id previously joined // getting this from user info
            guard let locationAlreadyJoinedId = (snapshot.value as? [String])?[1] else { return }
            self.executeLeavingTeam(locationAlreadyJoinedId: locationAlreadyJoinedId)
        }
    }
    
    func executeLeavingTeam(locationAlreadyJoinedId: String) {
        //set new count (remove from team) decrement
        
        print("ID of previous location: \(locationAlreadyJoinedId)")
        
        FirebaseDBClient.businessesRef.child(locationAlreadyJoinedId).observeSingleEvent(of: .value) { (snapshot) in
            guard var currentCount = snapshot.value as? Int else { return }
            
            //joining team
            print("count of prev location is  \(currentCount)")
            currentCount -= 1
            //leaving previous team -1 count in businesses
            FirebaseDBClient.businessesRef.child(locationAlreadyJoinedId).setValue(currentCount)
        }
        //modifiying current team of user
        let arrJoined: [String] = ["joined", location.id]
        guard let userID = user?.uid else { return }
        FirebaseDBClient.userInfoRef.child(userID).setValue(arrJoined)
        joinTeamButton.isEnabled = false //cannot join since already joined
        leaveTeamButton.isEnabled = true
        chatButton.isEnabled = true // in team
        let referenceTeamCount = FirebaseDBClient.businessesRef.child(location.id)
        LocationsViewController.shared.count += 1
        referenceTeamCount.setValue(LocationsViewController.shared.count)
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
