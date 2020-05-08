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
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createProfileButton: UIBarButtonItem!
    
    var userInfo: UserInfo?
    let user = Auth.auth().currentUser
    var initialUserInfo: [String] = Array(repeating: "", count: 4)
    var initialPhoto: UIImage!
    
    var isNameDifferent: Bool {
        nameField.text != initialUserInfo[0]
    }
    var isUsernameDifferent: Bool {
        usernameField.text != initialUserInfo[1]
    }
    var isBioDifferent: Bool {
        return bioTextView.text != initialUserInfo[2]
    }
    var isAgeDifferent: Bool {
        ageField.text != initialUserInfo[3]
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
            initialUserInfo[2] = "Enter a bio..."
            bioTextView.text = "Enter a bio..."
            bioTextView.textColor = .placeholderText
            bioTextView.selectedTextRange = bioTextView.textRange(from: bioTextView.beginningOfDocument, to: bioTextView.beginningOfDocument)
        }
        else {
            initialUserInfo[2] = info.bio
            bioTextView.text = info.bio
        }
        
        initialUserInfo[0] = info.name
        initialUserInfo[1] = info.username
        initialUserInfo[3] = info.age
        
        nameField.text = info.name
        usernameField.text = info.username
        ageField.text = info.age
        profilePicture.image = initialPhoto
        profilePicture.layer.cornerRadius = 10
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
        
        let alert = UIAlertController(title: "Are you sure you want to cancel?", message: "There are unsaved changes that will be deleted.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Continue Updating Profile", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
                    self.view.window?.rootViewController = profileVC
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
