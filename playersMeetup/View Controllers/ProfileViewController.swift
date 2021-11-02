//
//  ProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 4/29/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage
import Foundation
import Lottie
class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var lottieView: UIView!
    static var assignedStringColor: String = UIColor.toHexString(UIColor.random)()
    var handle: AuthStateDidChangeListenerHandle?
    let animationView = AnimationView()
    let user: User? =  FirebaseAuthClient.getUser()
    var userInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "",color: "")
    var otherUserID: String = ""
    
    // MARK: - VC Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBouncingBallAnimation()
        
        if !otherUserID.isEmpty {
            loadUserProfile(userID: otherUserID)
        }
        else if let userID = user?.uid {
            loadUserProfile(userID: userID)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = FirebaseAuthClient.addLoginStateListener(currentUser: self.user) { isSignedIn in
            if !isSignedIn {
                Navigation.goToSignUp(window: self.view.window)
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = handle {
            FirebaseAuthClient.removeLoginStateListener(handle: handle)
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        FirebaseAuthClient.signOut()
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Profile Loading
    
    func loadUserProfile(userID: String) {
        FirebaseDBClient.usersRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let name = value?["name"] as? String
            let username = value?["username"] as? String
            let bio = value?["bio"] as? String
            let photoURLString = value?["photoURL"] as? String
            let age = value?["age"] as? String
            
            if let _ = URL(string: photoURLString ?? "") {
                self.loadProfilePicture(userID: userID)
            }
            else {
                self.editButton.isEnabled = true
            }
            self.userInfo = UserInfo(username: username, name: name, bio: bio, age:age, photoURL: photoURLString, color: ProfileViewController.self.assignedStringColor) // here
            
            if self.userInfo.name.isEmpty {
                self.nameLabel.text = "No name"
            }
            else {
                self.nameLabel.text = self.userInfo.name
            }
            if self.userInfo.username.isEmpty {
                self.usernameLabel.text = "No username"
            }
            else {
                self.usernameLabel.text = self.userInfo.username
            }
            if self.userInfo.bio.isEmpty {
                self.bioTextView.text = "No bio"
            }
            else {
                self.bioTextView.text = self.userInfo.bio
            }
            if self.userInfo.age.isEmpty {
                self.ageLabel.text = "No Age"
            }
            else {
                self.ageLabel.text = "Age: \(self.userInfo.age)"
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadProfilePicture(userID: String) {
        FirebaseManager.dbClient.retrieveProfilePicture(userID: userID) { result in
            switch result {
            case .success(let image):
                self.profilePicture.image = image
                self.profilePicture.configureProfilePicture()
                self.editButton.isEnabled = true
            case .failure(let error):
                // TODO: Set placeholder image
                // self.profilePicture.image = placeholderProfilePicture
                self.showErrorAlert(with: error)
                print("Error retrieving image: \(error)")
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.userInfo = self.userInfo
            editProfileVC.initialPhoto = self.profilePicture.image
        }
    }
    
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
}
