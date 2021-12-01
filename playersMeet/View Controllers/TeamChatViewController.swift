//
//  TeamChatViewController.swift
//  playersMeet
//
//  Created by Haitao Huang on 5/4/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MessageInputBar

class TeamChatViewController: UIViewController, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var teamID: String! // teamID is the selected location
    let commentBar = MessageInputBar()
    var showsCommentBar = true
    let ref = Database.database().reference()
    var messages: [ChatMessage] = []
    let currentUser: User? = FirebaseAuthClient.getUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
        setupMessageBar()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    func loadMessages() {
        FirebaseManager.dbClient.retrieveMessages(at: teamID) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                self.messages.append(message)
                self.scrollToBottom()
                self.tableView.reloadData()
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        guard let userID = currentUser?.uid else { return }
        FirebaseManager.dbClient.sendMessage(text, from: userID, to: teamID) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.commentBar.inputTextView.text = nil
                self.becomeFirstResponder()
                self.commentBar.inputTextView.resignFirstResponder()
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func setupMessageBar() {
        commentBar.delegate = self
        commentBar.inputTextView.placeholder = "Type message..."
        commentBar.sendButton.title = "Send"
        commentBar.sendButton.setTitleColor(.systemOrange, for: .normal)
        commentBar.backgroundView.backgroundColor = .systemBackground
        commentBar.inputTextView.font = UIFont(descriptor: .init(name: "Futura", size: 17), size: 17)
        commentBar.inputTextView.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let profileVC = segue.destination as! ProfileViewController
            let tapRecognizer = sender as! customTapGestureRecognizer
            profileVC.teammateID = tapRecognizer.userID
        }
    }
    
    @objc func showProfile(sender: customTapGestureRecognizer) {
        commentBar.inputTextView.resignFirstResponder()
        self.performSegue(withIdentifier: "toProfile", sender: sender)
    }
}

// MARK: - Table View

extension TeamChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        if (Auth.auth().currentUser!.uid == (message.userID)) {
            cell.nameLabel.text = "\(message.username) (Me)"
            cell.nameLabel.textColor = UIColor.orange
        } else {
            cell.nameLabel.text = message.username
            let col: String = message.color
            if col == "#000000"{
                let uiColor: UIColor = UIColor(hexString: "#808080")
                cell.nameLabel.textColor = uiColor
            }
            else{
                let uiColor: UIColor = UIColor(hexString: col)
                cell.nameLabel.textColor = uiColor
            }
        }
        
        cell.msgLabel.text = message.text
        
        let date = Date(timeIntervalSince1970: message.createdAt)
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "PST")
        formatter.dateFormat = "h:mma, MM/dd/yyyy"
        
        cell.createdAtLabel.text = formatter.string(from: date)
        cell.tapRecognizer.addTarget(self, action: #selector(showProfile))
        cell.tapRecognizer.userID = message.userID
        cell.nameLabel.gestureRecognizers = []
        cell.nameLabel.gestureRecognizers!.append(cell.tapRecognizer)
        return cell
    }
}
