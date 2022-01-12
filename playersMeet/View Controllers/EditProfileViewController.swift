//
//  CreateProfileViewController.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 5/2/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
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
    
    let user: User
    let userState: UserState
    
    var userInfo: UserInfo
    let originalUserInfo: UserInfo
    let originalPhoto: UIImage?
    
    let bioPlaceholder: String = "Enter a bio..."
    
    // MARK: - Validation
    
    var isNameDifferent: Bool {
        nameField.text != originalUserInfo.name
    }
    var isUsernameDifferent: Bool {
        usernameField.text != originalUserInfo.username
    }
    var isBioDifferent: Bool {
        return bioTextView.text != originalUserInfo.bio
    }
    var isAgeDifferent: Bool {
        ageField.text != originalUserInfo.age
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
    
    static func instantiate(user: User, userState: UserState, originalPhoto: UIImage?) -> EditProfileViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditProfileViewController") { coder in
            EditProfileViewController(coder: coder, user: user, userState: userState, originalPhoto: originalPhoto)
        }
    }
    
    init?(coder: NSCoder, user: User, userState: UserState, originalPhoto: UIImage?) {
        self.user = user
        self.userState = userState
        switch userState {
        case .newUser:
            self.userInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "", color: "")
            self.originalUserInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "", color: "")
        case .existingUser(let userInfo):
            self.userInfo = userInfo
            self.originalUserInfo = userInfo
        }
        self.originalPhoto = originalPhoto
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        bioTextView.configure()
        profilePicture.configureProfilePicture()
        
        setNavigationItem()
        setProfileFields()
        profilePicture.image = originalPhoto
    }
    
    override func viewWillLayoutSubviews() {
        isModalInPresentation = isAnythingDifferent
    }
    
    // MARK: - Delegates
    
    private func setDelegates() {
        nameField.delegate = self
        usernameField.delegate = self
        bioTextView.delegate = self
    }
    
    // MARK: - Profile Updating
    
    @objc func cancelProfileUpdate() {
        if isAnythingDifferent {
            self.showCancelProfileUpdateAlert()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func saveProfile() {
        guard isAnythingDifferent else {
            return
        }
        saveFormFields()
        
        guard !profilePictureChanged else {
            uploadProfilePicture(userID: user.uid)
            return
        }
        
        updateProfile()
    }
    
    func updateProfile() {
        Task {
            do {
                try await FirebaseManager.dbClient.updateUserProfile(userID: user.uid, userInfo: userInfo)
                guard let tabBarController = self.presentingViewController as? UITabBarController,
                      let navigationController = tabBarController.selectedViewController as? UINavigationController,
                      let profileVC = navigationController.viewControllers[0] as? ProfileViewController else {
                          // Creating profile after signup. Need to instantiate profileVC
                          Navigation.goToHome(window: self.view.window)
                          return
                      }
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        print("Could not load updated profile. EditProfileVC")
                        return
                    }
                    profileVC.loadUserProfile(userID: self.user.uid)
                }
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    func saveFormFields() {
        userInfo.name = nameField.text!
        userInfo.username = usernameField.text!
        userInfo.age = ageField.text!
        
        let bio = bioTextView.text ?? ""
        userInfo.bio = bio != bioPlaceholder ? bio : ""
    }
    
    func setProfileFields() {
        nameField.text = originalUserInfo.name
        usernameField.text = originalUserInfo.username
        ageField.text = originalUserInfo.age
        
        if originalUserInfo.bio.isEmpty { bioTextView.reset(with: bioPlaceholder) }
        else { bioTextView.text = originalUserInfo.bio }
    }
    
    // MARK: - Profile Picture
    
    func uploadProfilePicture(userID: String) {
        guard let newProfilePicture = profilePicture.image?.pngData() else {
            showErrorAlert(with: ImageError.nilImage)
            return
        }
        Task {
            do {
                let photoDownloadURL = try await FirebaseManager.dbClient.uploadProfilePicture(userID: userID, imageData: newProfilePicture, imageType: .png)
                userInfo.photoURL = photoDownloadURL
                updateProfile()
            } catch {
                showErrorAlert(with: error)
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
        if userInfo.photoURL.isEmpty {
            profilePicture.configureProfilePicture()
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
    
    // Found here: https://stackoverflow.com/a/27652289/13194066
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.reset(with: bioPlaceholder)
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
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    @IBAction func usernameChanged(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    func textViewDidChange(_ textView: UITextView) {
        isModalInPresentation = isAnythingDifferent
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    @IBAction func ageChanged(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    @IBAction func nameEndedEdit(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    @IBAction func usernameEndedEdit(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    @IBAction func ageEndedEdit(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: -100, up: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isModalInPresentation = isAnythingDifferent
        navigationItem.rightBarButtonItem?.isEnabled = buttonsEnabled
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

extension EditProfileViewController {
    func setNavigationItem() {
        switch userState {
        case .newUser:
            navigationItem.title = "Create Profile"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfile))
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .existingUser(_):
            navigationItem.title = "Edit Profile"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelProfileUpdate))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfile))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}
