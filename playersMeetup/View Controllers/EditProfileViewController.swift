//
//  CreateProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/2/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createProfileButton: UIBarButtonItem!
    
    var userInfo: UserInfo?
    let user = FirebaseAuthClient.getUser()
    var initialUserInfo: UserInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "", color: "")
    var initialPhoto: UIImage!
    
    var isNameDifferent: Bool {
        nameField.text != initialUserInfo.name
    }
    var isUsernameDifferent: Bool {
        usernameField.text != initialUserInfo.username
    }
    var isBioDifferent: Bool {
        return bioTextView.text != initialUserInfo.bio
    }
    var isAgeDifferent: Bool {
        ageField.text != initialUserInfo.age
    }
    var isAnythingDifferent: Bool {
        (isNameDifferent || isUsernameDifferent || isBioDifferent || isAgeDifferent) || profilePictureChanged
    }
    var areNameOrUsernameEmpty: Bool {
        nameField.text?.isEmpty ?? true || usernameField.text?.isEmpty ?? true
    }
    var profilePictureChanged: Bool = false
    
    var buttonsEnabled: Bool {
        isAnythingDifferent && !areNameOrUsernameEmpty
    }
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        usernameField.delegate = self
        bioTextView.delegate = self
        
        guard let info = userInfo else {    // Creating profile after signup
            bioTextView.text = "Enter a bio..."
            bioTextView.textColor = .placeholderText
            bioTextView.selectedTextRange = bioTextView.textRange(from: bioTextView.beginningOfDocument, to: bioTextView.beginningOfDocument)
            
            userInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "", color: ProfileViewController.self.assignedStringColor)
            return
        }
        
        if info.bio.isEmpty {
            initialUserInfo.bio = "Enter a bio..."
            bioTextView.text = "Enter a bio..."
            bioTextView.textColor = .placeholderText
            bioTextView.selectedTextRange = bioTextView.textRange(from: bioTextView.beginningOfDocument, to: bioTextView.beginningOfDocument)
        }
        else {
            initialUserInfo.bio = info.bio
            bioTextView.text = info.bio
        }
        
        initialUserInfo.name = info.name
        initialUserInfo.username = info.username
        initialUserInfo.age = info.age
        
        nameField.text = info.name
        usernameField.text = info.username
        ageField.text = info.age
        
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor.separator.cgColor
        bioTextView.layer.cornerRadius = 4
        
        profilePicture.image = initialPhoto
        profilePicture.layer.cornerRadius = 15
        profilePicture.layer.borderWidth = 4
        profilePicture.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    override func viewWillLayoutSubviews() {
        isModalInPresentation = isAnythingDifferent
    }
    
    // MARK: - Profile Updating
    
    @IBAction func cancelProfileUpdate(_ sender: UIBarButtonItem) {
        guard isAnythingDifferent else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.showCancelProfileUpdateAlert()
    }
    
    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        guard let userID = user?.uid else {
            return
        }
        guard isAnythingDifferent else {
            print("Nothing changed")
            return
        }
        userInfo?.name = nameField.text!
        userInfo?.username = usernameField.text!
        let bio = bioTextView.text ?? ""
        if bio != "Enter a bio..." {
            userInfo?.bio = bio
        }
        else {
            userInfo?.bio = ""
        }
        userInfo?.age = ageField.text!
        
        guard !profilePictureChanged else {
            uploadProfilePicture(userID: userID)
            return
        }
        
        updateProfile(userID: userID)
    }
    
    func updateProfile(userID: String) {
        guard let userInfo = userInfo else {
            print("Can't update profile: User info is nil")
            return
        }
        FirebaseManager.dbClient.updateUserProfile(userID: userID, userInfo: userInfo) { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
                guard let tabBarController = self.presentingViewController as? UITabBarController,
                      let navigationController = tabBarController.selectedViewController as? UINavigationController,
                      let profileVC = navigationController.viewControllers[0] as? ProfileViewController else {
                          // Creating profile after signup. Need to instantiate profileVC
                          Navigation.goToHome(window: self.view.window)
                          return
                      }
                self.dismiss(animated: true) {
                    profileVC.loadUserProfile(userID: userID)
                }
            case .failure(let error): self.showErrorAlert(with: error)
            }
        }
    }
    
    // MARK: - Profile Picture
    
    func uploadProfilePicture(userID: String) {
        guard let newProfilePicture = profilePicture.image?.pngData() else {
            self.showErrorAlert(with: ImageError.nilImage)
            return
        }
        
        FirebaseManager.dbClient.uploadProfilePicture(userID: userID, imageData: newProfilePicture, imageType: .png) { result in
            switch result {
            case .success(let photoDownloadURL):
                self.userInfo?.photoURL = photoDownloadURL
                self.updateProfile(userID: userID)
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    @IBAction func changeProfilePicture(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.openCamera(imagePicker: imagePicker)
            }))
        }
        alert.addAction(UIAlertAction(title: "Choose Photo from Gallery", style: .default, handler: { _ in
            self.openPhotoGallery(imagePicker: imagePicker)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoGallery(imagePicker: UIImagePickerController) {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 800, height: 800)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        profilePicture.image = scaledImage
        if let _ = userInfo?.photoURL.isEmpty {
            profilePicture.layer.cornerRadius = 10
            profilePicture.layer.borderWidth = 4
            profilePicture.layer.borderColor = UIColor.systemGray.cgColor
        }
        profilePictureChanged = true
        
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Text Fields/View Helpers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "Enter a bio..."
            textView.textColor = .placeholderText
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == .placeholderText && !text.isEmpty {
            textView.textColor = .label
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == .placeholderText {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }
    
    @IBAction func usernameChanged(_ sender: UITextField) {
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }        
    
    func textViewDidChange(_ textView: UITextView) {
        isModalInPresentation = isAnythingDifferent
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }
    
    @IBAction func ageChanged(_ sender: UITextField) {
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }
    
    @IBAction func nameEndedEdit(_ sender: UITextField) {
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }
    
    @IBAction func usernameEndedEdit(_ sender: UITextField) {
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }
    
    @IBAction func ageEndedEdit(_ sender: UITextField) {
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: -100, up: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isModalInPresentation = isAnythingDifferent
        saveButton.isEnabled = buttonsEnabled
        createProfileButton.isEnabled = buttonsEnabled
        moveTextView(textView, moveDistance: -100, up: false)
    }
    
    func moveTextView(_ textView: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration) {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        }
    }
}
