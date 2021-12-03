//
//  TeamChatViewController.swift
//  playersMeet
//
//  Created by Haitao Huang on 5/4/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageInputBar

class TeamChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var teamID: String! // teamID is the selected location
    let messageBar = MessageInputBar()
    var showsMessageBar = true
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
    
    func sendMessage(text: String) {
        guard let userID = currentUser?.uid else { return }
        FirebaseManager.dbClient.sendMessage(text, from: userID, to: teamID) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.messageBar.inputTextView.text = nil
                self.becomeFirstResponder()
                self.messageBar.inputTextView.resignFirstResponder()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            guard let profileVC = segue.destination as? ProfileViewController,
                  let userID = sender as? String else { return }
            profileVC.teammateID = userID
        }
    }
    
    func showProfile(for userID: String) {
        messageBar.inputTextView.resignFirstResponder()
        self.performSegue(withIdentifier: "toProfile", sender: userID)
    }
}

extension TeamChatViewController: MessageCellDelegate {
    func didTapNameLabel(userID: String) {
        showProfile(for: userID)
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
        cell.message = message
        cell.delegate = self
        return cell
    }
}

// MARK: Message Input Bar

extension TeamChatViewController: MessageInputBarDelegate {
    func setupMessageBar() {
        messageBar.delegate = self
        messageBar.inputTextView.placeholder = "Type message..."
        messageBar.sendButton.title = "Send"
        messageBar.sendButton.setTitleColor(.systemOrange, for: .normal)
        messageBar.backgroundView.backgroundColor = .systemBackground
        messageBar.inputTextView.font = UIFont(descriptor: .init(name: "Futura", size: 17), size: 17)
        messageBar.inputTextView.becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        sendMessage(text: text)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        messageBar.inputTextView.text = nil
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return messageBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsMessageBar
    }
}
