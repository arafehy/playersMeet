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
        LocationsViewController.shared.count = LocationsViewController.shared.count-1
        usersCounterLabel.text = String(format: "%d",LocationsViewController.shared.count)
        leaveTeamOutlet?.isEnabled = false
        joinTeamOutlet?.isEnabled = true
        let reference = LocationsViewController.ref.child(LocationsViewController.selectedId)
        reference.setValue(LocationsViewController.shared.count)
    }
    @IBOutlet weak var usersCounterLabel: UILabel!
    
    @IBAction func joinTeamAction(_ sender: Any) {
        
        joinTeamOutlet?.isEnabled = false
        leaveTeamOutlet?.isEnabled = true
        if(joinedTeam == false){
            
            LocationsViewController.shared.count = LocationsViewController.shared.count+1
            usersCounterLabel.text = String(format: "%d",LocationsViewController.shared.count )
            let reference = LocationsViewController.ref.child(LocationsViewController.selectedId)
            reference.setValue(LocationsViewController.shared.count)
            print("joined team is \(joinedTeam)")
            joinedTeam = true
        }
        else if(joinedTeam == true){
            print("you are already in a team")
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
