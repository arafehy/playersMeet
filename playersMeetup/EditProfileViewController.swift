//
//  CreateProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/2/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    var userInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard userInfo != nil, !(userInfo?.bio ?? "").isEmpty else {    // Creating profile after signup
            self.bioTextView.text = "Enter a bio..."
            return
        }
        
        self.nameField.text = self.userInfo?.name
        self.usernameField.text = self.userInfo?.username
        self.bioTextView.text = self.userInfo?.bio
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
