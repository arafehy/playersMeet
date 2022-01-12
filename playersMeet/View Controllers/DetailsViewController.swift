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
    
    let location: Location
    var playerCount: Int = 0 {
        didSet {
            setPlayerCountLabel()
        }
    }
    let user: User
    var isAtLocation: Bool {
        location.id == CurrentSession.locationID
    }
    
    let delegate: DetailsViewControllerDelegate?
    let coordinator: LocationDetailsFlow?
    
    // MARK: - VC Life Cycle
    
    static func instantiate(user: User, location: Location, delegate: DetailsViewControllerDelegate, coordinator: LocationDetailsFlow?) -> DetailsViewController {
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsViewController") { coder in
            DetailsViewController(coder: coder, user: user, location: location, delegate: delegate, coordinator: coordinator)
        }
        detailsVC.navigationItem.title = location.name
        return detailsVC
    }
    
    init?(coder: NSCoder, user: User, location: Location, delegate: DetailsViewControllerDelegate, coordinator: LocationDetailsFlow?) {
        self.user = user
        self.location = location
        self.delegate = delegate
        self.coordinator = coordinator
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinTeamButton.rounded()
        leaveTeamButton.rounded()
        chatButton.rounded()
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
            self.playerCount = playerCount
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func leaveTeamAction(_ sender: Any) {
        Task {
            do {
                let locationID = try await FirebaseManager.dbClient.leaveLocationWith(ID: location.id, for: user.uid)
                handleLocationChange(locationID)
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    @IBAction func joinTeamAction(_ sender: Any) {
        guard CurrentSession.locationID == nil else {
            showSwitchTeamAlert()
            return
        }
        
        Task {
            do {
                let locationID = try await FirebaseManager.dbClient.joinLocationWith(ID: location.id, for: user.uid)
                handleLocationChange(locationID)
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    func switchLocation(alert: UIAlertAction) {
        guard let currentLocationID = CurrentSession.locationID else { return }
        Task {
            do {
                let locationID = try await FirebaseManager.dbClient.switchLocation(for: user.uid, from: currentLocationID, to: location.id)
                handleLocationChange(locationID)
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    func handleLocationChange(_ locationID: String?) {
        delegate?.didChangeLocation(fromID: CurrentSession.locationID, toID: locationID)
        CurrentSession.locationID = locationID
        self.setButtonsAndLabels()
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
    
    @IBAction func chatButtonTapped() {
        coordinator?.coordinateToChat(teamID: location.id)
    }
}

// MARK: - Map

extension DetailsViewController: MKMapViewDelegate {
    func initializeMap() {
        locationMapView.delegate = self
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
        setMapRegion(with: coordinates)
        setMapPin(at: coordinates)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToFitMapPins()
    }
    
    func setMapRegion(with center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 800, longitudinalMeters: 800)
        locationMapView.setRegion(region, animated: true)
    }
    
    func zoomToFitMapPins() {
        locationMapView.showAnnotations(locationMapView.annotations, animated: true)
    }
    
    func setMapPin(at coordinates: CLLocationCoordinate2D) {
        let locationPin = MKPointAnnotation()
        locationPin.coordinate = coordinates
        locationPin.title = location.name
        locationPin.subtitle = Formatter.getReadableMeasurement(location.distance)
        locationMapView.addAnnotation(locationPin)
        locationMapView.selectAnnotation(locationPin, animated: true)
    }
    
    @IBAction func tappedMap(_ sender: UITapGestureRecognizer) {
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
        let locationItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        locationItem.name = location.name
        locationItem.openInMaps(launchOptions: [MKLaunchOptionsMapCenterKey: coordinates])
    }
}

protocol DetailsViewControllerDelegate {
    func didChangeLocation(fromID: String?, toID: String?)
}
