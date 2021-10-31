//
//  DetailsViewController.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps
class DetailsViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet weak var leaveTeamOutlet: UIButton!
    @IBOutlet weak var joinTeamOutlet: UIButton!
    @IBOutlet weak var youInTeamLabel: UILabel!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var chatButton: UIButton!
    var latSelected: String = ""
    var longSelected: String = ""
    var location: [String: Any]!
    let user: User? = FirebaseAuthClient.getUser()
    @IBAction func leaveTeamAction(_ sender: Any) {
        leaveTeamOutlet?.isEnabled = false
        joinTeamOutlet?.isEnabled = true
        self.chatButton.isEnabled = false //not in team
        
        let referenceTeamCount = FirebaseReferences.businessesRef.child(LocationsViewController.selectedId)
        FirebaseReferences.businessesRef.child(LocationsViewController.selectedId).observeSingleEvent(of: .value) { (snapshot) in
            let countBeforeLeaving = snapshot.value
            LocationsViewController.shared.count = countBeforeLeaving as! Int - 1
            
            print("leaving this id: \(LocationsViewController.selectedId)")
            print("after leaving count is \(LocationsViewController.shared.count)")
            //        LocationsViewController.shared.count = LocationsViewController.shared.count-1
            referenceTeamCount.setValue(LocationsViewController.shared.count)
            if LocationsViewController.shared.count == 0 {
                self.usersCounterLabel.text = "No players are available at the moment"
            }
            else if LocationsViewController.shared.count == 1 {
                self.usersCounterLabel.text = "There is 1 player available"
            }
            else{
                self.usersCounterLabel.text = "There are \(LocationsViewController.shared.count) players here"
            }
            
            //        String(format: "%d",LocationsViewController.shared.count)
            
            let array: [String] = ["not joined","0"]
            FirebaseReferences.userInfoRef.child(self.user!.uid).setValue(array)
            self.youInTeamLabel.text = ""
        }
        
    }
    @IBOutlet weak var usersCounterLabel: UILabel!
    
    @IBAction func joinTeamAction(_ sender: Any) {
        //        if ref.child( SignUpViewController.signUpController.userID) as! String == "not joined"
        FirebaseReferences.userInfoRef.child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            print((snapshot.value as? [String])![0])
            if (snapshot.value as? [String])?[0] == "not joined"
            {
                self.joinTeamOutlet?.isEnabled = false
                self.leaveTeamOutlet?.isEnabled = true
                LocationsViewController.shared.count = LocationsViewController.shared.count+1
                //                    self.usersCounterLabel.text = String(format: "%d",LocationsViewController.shared.count )
                if LocationsViewController.shared.count == 0 {
                    self.usersCounterLabel.text = "No players are available at the moment"
                }
                else if LocationsViewController.shared.count == 1 {
                    self.usersCounterLabel.text = "There is 1 player available"
                }
                else{
                    self.usersCounterLabel.text = "There are \(LocationsViewController.shared.count) players here"
                }
                //businesses count modification
                let referenceTeamCount = FirebaseReferences.businessesRef.child(LocationsViewController.selectedId)
                referenceTeamCount.setValue(LocationsViewController.shared.count)
                //userInfo modification
                let array: [String] = ["joined",DetailsViewController.selectedLocationId]
                FirebaseReferences.userInfoRef.child(self.user!.uid).setValue(array)
                self.youInTeamLabel.text = "You are in this team"
                self.chatButton.isEnabled = true
            }
            else{
                
                self.joinTeamOutlet?.isEnabled = true
                self.leaveTeamOutlet?.isEnabled = false
                self.chatButton.isEnabled = false //not in team
                let alert = UIAlertController(title: "Are you sure you want to join?", message: "You can only join one team at a time. This will remove you from another team.", preferredStyle: .alert) //show what other team - later
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:self.changeLocation))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
    }
    func changeLocation(alert: UIAlertAction!){
        
        //get id of loctaion of the user now then find it in businesses and decrement count
        //ref here is for userInfo
        self.youInTeamLabel.text = "You are now in this team"
        self.chatButton.isEnabled = true
        FirebaseReferences.userInfoRef.child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            //get location id previously joined //getting this from user info
            let  locationAlreadyJoinedId = (snapshot.value as? [String])?[1]
            //            print("Location already joined \(locationAlreadyJoinedId)")
            self.executeLeavingTeam(locationAlreadyJoinedId: locationAlreadyJoinedId!)
        }
    }
    func executeLeavingTeam(locationAlreadyJoinedId: String){
        //set new count (remove from team) decrement
        
        print("id of location previous")
        print(locationAlreadyJoinedId)
        
        FirebaseReferences.businessesRef.child(locationAlreadyJoinedId).observeSingleEvent(of: .value) { (snapshot) in
            var currentCount = snapshot.value as! Int
            
            //joining team
            print("count of prev location is  \(currentCount)")
            currentCount = currentCount - 1
            //leaving previous team -1 count in businesses
            FirebaseReferences.businessesRef.child(locationAlreadyJoinedId).setValue(currentCount)
        }
        //modifiying current team of user
        let arrJoined: [String] = ["joined",DetailsViewController.selectedLocationId]
        FirebaseReferences.userInfoRef.child(user!.uid).setValue(arrJoined)
        self.joinTeamOutlet?.isEnabled = false //cannot join since already joined
        self.leaveTeamOutlet?.isEnabled = true
        self.chatButton.isEnabled = true // in team
        let referenceTeamCount = FirebaseReferences.businessesRef.child(LocationsViewController.selectedId)
        LocationsViewController.shared.count = LocationsViewController.shared.count+1
        referenceTeamCount.setValue(LocationsViewController.shared.count)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("!map tapped!")
        if let UrlNavigation = URL.init(string: "comgooglemaps://") {
            if UIApplication.shared.canOpenURL(UrlNavigation){
                if !longSelected.isEmpty && !latSelected.isEmpty {
                    let lat = latSelected
                    let longi = longSelected
                    if let urlDestination = URL.init(string: "comgooglemaps://?saddr=&daddr=\(lat),\(longi)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
                    }
                }
            }
            else {
                NSLog("Can't use comgooglemaps://");
                self.openTrackerInBrowser()
                
            }
        }
        else
        {
            NSLog("Can't use comgooglemaps://");
            self.openTrackerInBrowser()
        }
    }
    func openTrackerInBrowser(){
        if !longSelected.isEmpty && !latSelected.isEmpty {
            let lat = latSelected
            let longi = longSelected
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(longi)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
            }
        }
    }
    static var selectedLocationId: String = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        joinTeamOutlet.rounded()
        leaveTeamOutlet.rounded()
        chatButton.rounded()
        
        
        self.navigationItem.title = location["name"] as? String
        
        
        
        
        //        getDirectionsButton.layer.zPosition = -1
        //        overrideUserInterfaceStyle = .light
        leaveTeamOutlet.isEnabled = false
        self.chatButton.isEnabled = false
        //get value from database
        let reference = FirebaseReferences.businessesRef.child(LocationsViewController.selectedId)
        print("selected id")
        reference.observeSingleEvent(of: .value){
            (snapshot) in print(snapshot.key)
            DetailsViewController.selectedLocationId = snapshot.key
        }
        //get selected location id from selected row
        //synchronizing datatase count with label text from the location selected
        reference.observe(DataEventType.value, with: { (snapshot) in
            ///listen in realtime to whenever it updates
            //            var snapCount = (snapshot.value as AnyObject).description //this was used when just showing count of players
            LocationsViewController.shared.count = snapshot.value as! Int
            if LocationsViewController.shared.count == 0 {
                self.usersCounterLabel.text = "No players are available"
            }
            else if LocationsViewController.shared.count == 1 {
                self.usersCounterLabel.text = "There is 1 player available"
            }
            else{
                self.usersCounterLabel.text = "There are \(LocationsViewController.shared.count) players here"
            }
            
            
        })
        
        //check if user is already in team selected
        FirebaseReferences.userInfoRef.child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value as? [String])?[0] == "joined" && DetailsViewController.selectedLocationId == (snapshot.value as? [String])?[1] {
                print("Already in that team")
                //dont allow to join
                self.joinTeamOutlet?.isEnabled = false
                self.leaveTeamOutlet?.isEnabled = true
                self.youInTeamLabel.text = "You are in this team"
                self.chatButton.isEnabled = true
            }
            else{
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
}
