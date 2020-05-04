//
//  SignUpViewController.swift
//  playersMeetup
//
//  Created by Risha Ray on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    static let signUpController = SignUpViewController()
    static let ref = Database.database().reference().ref.child("userInfo") //doesnt need to be static fix
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    @IBAction func onSignUp(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!){ (user, error) in
        if error == nil {
          self.performSegue(withIdentifier: "toCreateProfile", sender: self)
        }
        else {
            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    static var userID: String = ""
    var usersInfo: [String:[String]] = [:]
    @IBAction func onSignIn(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
               if error == nil{
                    self.performSegue(withIdentifier: "loginToHome", sender: self)
                    //get user id
                SignUpViewController.userID = Auth.auth().currentUser!.uid
                print(SignUpViewController.userID)
                    //add current user to dictionary as not joined
                var array: [String] = [] //array with join info and team number
                array.append("not joined")
                array.append("team location")
                self.usersInfo[SignUpViewController.self.userID] = array
                    for (uid,hasJoined) in self.usersInfo{
                        SignUpViewController.self.ref.observeSingleEvent(of: .value) { (snapshot) in
                            if snapshot.hasChild(uid){
                                print("user is in database")
                            }
                            else{
                                print("adding user to database")
                                let newUser = SignUpViewController.self.ref.child(uid)
                                
                                newUser.setValue(hasJoined)
                            }
                        }
                    }
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
}

