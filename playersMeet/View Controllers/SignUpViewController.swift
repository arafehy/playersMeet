//
//  SignUpViewController.swift
//  playersMeet
//
//  Created by Risha Ray on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
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
        configureLoopingAnimation(animation: .loading, animationView: animationView, lottieView: lottieView)
    }
    
    // MARK: Button Actions
    
    @IBAction func onSignUp(_ sender: Any) {
        FirebaseAuthClient.createUser(email: emailField.text!, password: passwordField.text!) { result in
            switch result {
            case .success(let user):
                guard let user = user else {
                    print("User does not exist")
                    return
                }
                self.performSegue(withIdentifier: "toCreateProfile", sender: self)
                self.addUserToDBAsNotJoined(userID: user.uid)
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        FirebaseAuthClient.signIn(email: emailField.text!, password: passwordField.text!) { result in
            switch result {
            case .success(let user):
                guard let user = user else {
                    print("User does not exist")
                    return
                }
                self.addUserToDBAsNotJoined(userID: user.uid)
                Navigation.goToHome(window: self.view.window)
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    // MARK: Helpers
    
    func addUserToDBAsNotJoined(userID: String) {
        // add current user to dictionary as not joined
        let userInfo: [String: [String]] = [userID: ["not joined", "team location"]]
        FirebaseManager.dbClient.addUser(user: userInfo) { result in
            switch result {
            case .success(let uid):
                print("Added user with uid \(uid) to database")
            case .failure(let error):
                switch error {
                case DatabaseError.invalidInput:
                    self.showErrorAlert(with: error)
                default:
                    print("Error adding to database: \(error)")
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
