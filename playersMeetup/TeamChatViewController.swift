//
//  TeamChatViewController.swift
//  playersMeetup
//
//  Created by Haitao Huang on 5/4/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MessageInputBar

class TeamChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var teamId: String = LocationsViewController.selectedId //teamId is the selected location
    let commentBar = MessageInputBar()
    var showsCommentBar = true
    let ref = Database.database().reference()
    var msgData = [NSDictionary]()
    let currentUser: User? = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMsgs()
        
        commentBar.inputTextView.placeholder = "Type message..."
        commentBar.sendButton.title = "Send"
        commentBar.backgroundView.backgroundColor = .systemBackground
        commentBar.delegate = self
        
        commentBar.inputTextView.becomeFirstResponder()
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let msg = msgData[indexPath.row]
        if (Auth.auth().currentUser!.uid == (msg["user"] as! String)) {
            cell.nameLabel.text = "\(msg["username"] as! String) (Me)"
            cell.nameLabel.textColor = UIColor.orange
        } else {
            cell.nameLabel.text = msg["username"] as? String
            let col: String = msg["color"] as! String
            let uiColor: UIColor = UIColor(hexString: col)
            cell.nameLabel.textColor = uiColor
        }
        
        cell.msgLabel.text = msg["text"] as? String
        
        let date = Date(timeIntervalSince1970: msg["createdAt"] as! TimeInterval)
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "PST")
        formatter.dateFormat = "h:mma, MM/dd/yyyy"
        
        cell.createdAtLabel.text = formatter.string(from: date)
        cell.tapRecognizer.addTarget(self, action: #selector(showProfile))
        cell.nameLabel.gestureRecognizers = []
        cell.nameLabel.gestureRecognizers!.append(cell.tapRecognizer)
        return cell
    }
    
    func loadMsgs() {
        let msgsRef = Database.database().reference().child("teamChat/\(teamId)")
        
        msgsRef.queryOrdered(byChild: "createdAt")
            .observe(.childAdded)
            { (snapshot) in
                let msg = snapshot.value as? NSDictionary
                
                if let acutualMsg = msg {
                    self.msgData.append(acutualMsg)
                    
                    
                    self.scrollToBottom()
                    self.tableView.reloadData()
                }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let msgsRef = Database.database().reference().child("teamChat/\(teamId)").childByAutoId()
        FirebaseReferences.usersRef.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            let username = userInfo?["username"]
            let color = userInfo?["color"]
            
            
            //        let color:String = myColor.description
            //        print(color)
            let msgObject = [
                "user": Auth.auth().currentUser?.uid as Any,
                "text": text,
                "createdAt": NSDate().timeIntervalSince1970,
                "username" : username!,
                "color": color as Any
                ] as [String: Any]
            
            msgsRef.setValue(msgObject) { (error, ref) in
                if error != nil {
                    print("Error: \(String(describing: error))")
                }
            }
        }
        commentBar.inputTextView.text = nil
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.msgData.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func showProfile() {
        self.performSegue(withIdentifier: "toProfile", sender: UITapGestureRecognizer.self)
    }
}
