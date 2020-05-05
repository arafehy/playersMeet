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
import Lottie
class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var lottieView: UIView!
    let animationView = AnimationView()
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var playersMeetLabel: UILabel!
    static let signUpController = SignUpViewController()
    static let ref = Database.database().reference().ref.child("userInfo") //doesnt need to be static fix
    override func viewDidLoad() {
        super.viewDidLoad()
//        overrideUserInterfaceStyle = .light
        //custom ui
        signInButton.rounded()
        signUpButton.rounded()
//        
        animationView.animation = Animation.named("18709-loading")
        animationView.frame.size = lottieView.frame.size
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        playersMeetLabel.layer.zPosition = 1
        lottieView.addSubview(animationView)
        
//        animationView.layer.zPosition = 1
        emailField.layer.zPosition = 1
        emailField.layer.borderWidth = 1
        passwordField.layer.zPosition = 1
        signUpButton.layer.zPosition = 1
        emailField.layer.cornerRadius = 10
        emailField.layer.borderColor = UIColor.white.cgColor
        passwordField.layer.borderWidth = 1
        passwordField.layer.cornerRadius = 10
        passwordField.layer.borderColor = UIColor.white.cgColor
        passwordField.layer.borderWidth = 1
        emailField.delegate = self
        passwordField.delegate = self
        animationView.play()
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!){ (user, error) in
        if error == nil {
          self.performSegue(withIdentifier: "toCreateProfile", sender: self)
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
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let profileVC = storyboard.instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = profileVC
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
   
}

extension UITextField {
    func rounded() {
        
        // set rounded and white border
        self.layer.cornerRadius = 25
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        
    }
}

extension UIButton {
    func rounded() {
        
        // set rounded and white border
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
    }
}
