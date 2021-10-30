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
    
    // MARK: - Properties
    
    @IBOutlet weak var lottieView: UIView!
    let animationView = AnimationView()
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var playersMeetLabel: UILabel!
    static let signUpController = SignUpViewController()
    
    static var userID: String = ""
    var usersInfo: [String:[String]] = [:]
    
    // MARK: - VC Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        animationView.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.rounded()
        signUpButton.rounded()
        signUpButton.layer.zPosition = 1
        
        playersMeetLabel.layer.zPosition = 1
        
        emailField.configure()
        passwordField.configure()
        
        emailField.delegate = self
        passwordField.delegate = self
        configureBackgroundLoadingAnimation()
    }
    
    // MARK: Button Actions
    
    @IBAction func onSignUp(_ sender: Any) {
        FirebaseAuthClient.createUser(email: emailField.text!, password: passwordField.text!) { result in
            switch result {
            case .success(let user):
                self.performSegue(withIdentifier: "toCreateProfile", sender: self)
                
                SignUpViewController.userID = user!.uid
                print(SignUpViewController.userID)
                self.addUserToUnjoinedPlayerDB()
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        FirebaseAuthClient.signInUser(email: emailField.text!, password: passwordField.text!) { result in
            switch result {
            case .success(let user):
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let profileVC = storyboard.instantiateInitialViewController()
                self.view.window?.rootViewController = profileVC
                
                SignUpViewController.userID = user!.uid
                print(SignUpViewController.userID)
                self.addUserToUnjoinedPlayerDB()
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    func configureBackgroundLoadingAnimation() {
        animationView.animation = Animation.named("18709-loading")
        animationView.frame.size = lottieView.frame.size
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        lottieView.addSubview(animationView)
    }
    
    func addUserToUnjoinedPlayerDB() {
        // add current user to dictionary as not joined
        let array: [String] = ["not joined", "team location"] // array with join info and team number
        self.usersInfo[SignUpViewController.self.userID] = array
        FirebaseDBClient.shared.addUserToDBAsNotJoined(user: usersInfo)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
