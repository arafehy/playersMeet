//
//  SignUpViewController.swift
//  playersMeet
//
//  Created by Risha Ray on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import Lottie

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var playersMeetLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var lottieView: UIView!
    let animationView = AnimationView()

    // MARK: - VC Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        Task {
            do {
                try await FirebaseAuthClient.createUser(email: emailField.text!, password: passwordField.text!)
                performSegue(withIdentifier: "toCreateProfile", sender: self)
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        FirebaseAuthClient.signIn(email: emailField.text!, password: passwordField.text!) { result in
            switch result {
            case .success(let user):
                guard user != nil else { return }
                Navigation.goToHome(window: self.view.window)
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    // MARK: Text Fields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
