//
//  DetailsViewController.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class DetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var leaveTeamButton: UIButton!
    @IBOutlet weak var joinTeamButton: UIButton!
    @IBOutlet weak var youInTeamLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var playerCountLabel: UILabel!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    var location: Location!
    var playerCount: Int = 0 {
        didSet {
            setPlayerCountLabel()
        }
    }
    let user: User? = FirebaseAuthClient.getUser()
    var isAtLocation: Bool {
        location.id == CurrentSession.locationID
    }
    
    var delegate: DetailsViewControllerDelegate?
    
    // MARK: - VC Life Cycle
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseManager.dbClient.stopObservingPlayerCount(at: location.id)
    }
    
    // MARK: - Initialization
    
    func startPlayerCountObserver() {
        FirebaseManager.dbClient.observePlayerCount(at: location.id) { playerCount in
            // Listen in realtime to whenever it updates
            guard let playerCount = playerCount else {
                print("Player count for location with ID \(self.location.id) unavailable")
                return
            }
            self.playerCount = playerCount
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func leaveTeamAction(_ sender: Any) {
        guard let userID = user?.uid else { return }
        FirebaseManager.dbClient.leaveLocationWith(ID: location.id, for: userID) { [weak self] (result) in
            self?.handleLocationChange(result: result)
        }
    }
    
    @IBAction func joinTeamAction(_ sender: Any) {
        guard let userID = user?.uid else { return }
        
        guard CurrentSession.locationID == nil else {
            showSwitchTeamAlert()
            return
        }
        
        FirebaseManager.dbClient.joinLocationWith(ID: location.id, for: userID) { [weak self] (result) in
            self?.handleLocationChange(result: result)
        }
    }
    
    func switchLocation(alert: UIAlertAction) {
        guard let userID = user?.uid, let currentLocationID = CurrentSession.locationID else { return }
        FirebaseManager.dbClient.switchLocation(for: userID, from: currentLocationID, to: location.id) { [weak self] (result) in
            self?.handleLocationChange(result: result)
        }
    }
    
    func handleLocationChange(result: Result<String?, Error>) {
        switch result {
        case .success(let locationID):
            delegate?.didChangeLocation(fromID: CurrentSession.locationID, toID: locationID)
            CurrentSession.locationID = locationID
            self.setButtonsAndLabels()
        case .failure(let error):
            self.showErrorAlert(with: error)
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

extension DetailsViewController {
    func initializeMap() {
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
    }
}

protocol DetailsViewControllerDelegate {
    func didChangeLocation(fromID: String?, toID: String?)
}
