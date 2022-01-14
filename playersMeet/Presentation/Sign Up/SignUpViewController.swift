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
    
    let coordinator: SignUpFlow?
    
    // MARK: - VC Life Cycle
    
    static func instantiate(coordinator: SignUpFlow?) -> SignUpViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SignUpViewController") { coder in
            SignUpViewController(coder: coder, coordinator: coordinator)
        }
    }
    
    init?(coder: NSCoder, coordinator: SignUpFlow?) {
        self.coordinator = coordinator
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    @IBAction func signIn() {
        Task {
            do {
                try await FirebaseAuthClient.signIn(email: emailField.text!, password: passwordField.text!)
                coordinator?.signIn()
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    @IBAction func signUp() {
        Task {
            do {
                try await FirebaseAuthClient.createUser(email: emailField.text!, password: passwordField.text!)
                coordinator?.signUp()
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    // MARK: Text Fields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
