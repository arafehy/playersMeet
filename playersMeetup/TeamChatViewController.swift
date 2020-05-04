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
    
    var teamId: String = "8eqZnk53yNXIR86aIaYBVg"
    let commentBar = MessageInputBar()
    var showsCommentBar = true
    let ref = Database.database().reference()
    var msgData = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMsgs()
        
        commentBar.inputTextView.placeholder = "Type message..."
        commentBar.sendButton.title = "Send"
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
            cell.nameLabel.text = "Tom1996(You):"
            cell.nameLabel.textColor = UIColor.systemRed
        } else {
            cell.nameLabel.text = "Tom1996:"
            cell.nameLabel.textColor = UIColor.systemGreen
        }
        cell.msgLabel.text = msg["text"] as? String
        
        let date = Date(timeIntervalSince1970: msg["createdAt"] as! TimeInterval)
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "PST")
        formatter.dateFormat = "h:mma, MM/dd/yyyy"

        cell.createdAtLabel.text = formatter.string(from: date)
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
                
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let msgsRef = Database.database().reference().child("teamChat/\(teamId)").childByAutoId()
        
        let msgObject = [
            "user": Auth.auth().currentUser?.uid,
            "text": text,
            "createdAt": NSDate().timeIntervalSince1970
        ] as [String: Any]
        
        msgsRef.setValue(msgObject) { (error, ref) in
            if error != nil {
                print("Error: \(error)")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
