//
//  DetailsViewController.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController: UIViewController {
    var joinedTeam: Bool = false
    @IBOutlet weak var leaveTeamOutlet: UIButton!
    @IBOutlet weak var joinTeamOutlet: UIButton!
    @IBAction func leaveTeamAction(_ sender: Any) {
        leaveTeamOutlet?.isEnabled = false
        joinTeamOutlet?.isEnabled = true
        LocationsViewController.shared.count = LocationsViewController.shared.count-1
        usersCounterLabel.text = String(format: "%d",LocationsViewController.shared.count)
        
        let reference = LocationsViewController.ref.child(LocationsViewController.selectedId)
        reference.setValue(LocationsViewController.shared.count)
    }
    @IBOutlet weak var usersCounterLabel: UILabel!
    
    @IBAction func joinTeamAction(_ sender: Any) {
        
        joinTeamOutlet?.isEnabled = false
        leaveTeamOutlet?.isEnabled = true
            
            LocationsViewController.shared.count = LocationsViewController.shared.count+1
            usersCounterLabel.text = String(format: "%d",LocationsViewController.shared.count )
            let reference = LocationsViewController.ref.child(LocationsViewController.selectedId)
            reference.setValue(LocationsViewController.shared.count)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        leaveTeamOutlet.isEnabled = false
        //get value from database
        let reference = LocationsViewController.ref.child(LocationsViewController.selectedId)
       print("selected id \(reference)")
        //get selected location id from selected row
        
        reference.observe(DataEventType.value, with: { (snapshot) in
        ///listen in realtime to whenever it updates
            self.usersCounterLabel.text =  (snapshot.value as AnyObject).description
            LocationsViewController.shared.count = snapshot.value as! Int
        })

        // increment value in database
        
        //make first value stay the same until end game
    }

}
