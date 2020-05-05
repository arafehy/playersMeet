//
//  CreateProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/2/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createProfileButton: UIBarButtonItem!
    
    var initialPhoto: UIImage!
    
    var userInfo: UserInfo?
    let user = Auth.auth().currentUser
    var initialUserInfo: [String] = Array(repeating: "", count: 3)
    var isNameDifferent: Bool {
        nameField.text != initialUserInfo[0]
    }
    var isUsernameDifferent: Bool {
        usernameField.text != initialUserInfo[1]
    }
    var isBioDifferent: Bool {
        let bio = bioTextView.text
        return bio != initialUserInfo[2] && bio != "Enter a bio..."
    }
    var isAnythingDifferent: Bool {
        (isNameDifferent || isUsernameDifferent || isBioDifferent) || profilePictureChanged
    }
    var areNameOrUsernameEmpty: Bool {
        nameField.text?.isEmpty ?? true || usernameField.text?.isEmpty ?? true
    }
    
    var profilePictureChanged: Bool = false
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        usernameField.delegate = self
        bioTextView.delegate = self
        
        guard let info = userInfo else {    // Creating profile after signup
            self.bioTextView.text = "Enter a bio..."
            self.userInfo = UserInfo(username: "", name: "", bio: "", photoURL: "")
            return
        }
        
        guard !info.bio.isEmpty else {
            self.bioTextView.text = "Enter a bio..."
            return
        }
        
        initialUserInfo[0] = info.name
        initialUserInfo[1] = info.username
        initialUserInfo[2] = info.bio
        
        self.nameField.text = info.name
        self.usernameField.text = info.username
        self.bioTextView.text = info.bio
        self.profilePicture.image = initialPhoto
    }
    
    // MARK: - Profile Updating
    
    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        guard let userID = user?.uid else {
            return
        }
        guard isAnythingDifferent else {
            print("Nothing changed")
            return
        }
        self.userInfo?.name = self.nameField.text!
        self.userInfo?.username = self.usernameField.text!
        self.userInfo?.bio = self.bioTextView.text
        
        guard !profilePictureChanged else {
            uploadProfilePicture(userID: userID)
            return
        }
        
        updateProfile(userID: userID)
    }
    
    func updateProfile(userID: String) {
        guard let profileAsDictionary = userInfo?.asDictionary() else {
            print("Failed to convert to dictionary")
            return
        }
        FirebaseReferences.usersRef.child(userID).updateChildValues(profileAsDictionary) { (error, usersRef) in
            guard error == nil else {
                print("Failed to save profile")
                return
            }
            
            guard let tabBarController = self.presentingViewController as? UITabBarController,
                let navigationController = tabBarController.selectedViewController as? UINavigationController,
                let profileVC = navigationController.viewControllers[0] as? ProfileViewController else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileVC = storyboard.instantiateInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = profileVC
                    return
            }
            self.dismiss(animated: true) {
                profileVC.loadUserProfile(userID: userID)
            }
        }
    }
    
    // MARK: - Profile Picture
    
    func uploadProfilePicture(userID: String) {
        guard let newProfilePicture = profilePicture.image?.pngData() else {
            // TODO: Show error alert
            return
        }
        
        let profileRef = FirebaseReferences.imagesRef.child(userID)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        profileRef.putData(newProfilePicture, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                return
            }
            profileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                let photoURLString = downloadURL.absoluteString
                FirebaseReferences.usersRef.child("\(userID)/photoURL").setValue(photoURLString) { (error, userRef) in
                    guard error == nil else {
                        print("Failed to save photo url")
                        return
                    }
                    self.userInfo?.photoURL = photoURLString
                    self.updateProfile(userID: userID)
                }
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
        
        let size = CGSize(width: 200, height: 200)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        profilePicture.image = scaledImage
        profilePictureChanged = true
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Text Fields/View Helpers
    
    @IBAction func nameChanged(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    @IBAction func usernameChanged(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }        
    
    func textViewDidChange(_ textView: UITextView) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    @IBAction func nameEndedEdit(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    @IBAction func usernameEndedEdit(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
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
