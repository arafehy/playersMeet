//
//  MessageCell.swift
//  playersMeet
//
//  Created by Haitao Huang on 5/4/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    let tapRecognizer: customTapGestureRecognizer = customTapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with message: ChatMessage) {
        if (Auth.auth().currentUser!.uid == (message.userID)) {
            self.nameLabel.text = "\(message.username) (Me)"
            self.nameLabel.textColor = UIColor.orange
        } else {
            self.nameLabel.text = message.username
            let col: String = message.color
            if col == "#000000"{
                let uiColor: UIColor = UIColor(hexString: "#808080")
                self.nameLabel.textColor = uiColor
            }
            else{
                let uiColor: UIColor = UIColor(hexString: col)
                self.nameLabel.textColor = uiColor
            }
        }
        
        msgLabel.text = message.text
        createdAtLabel.text = Formatter.getReadableDate(timeInterval: message.createdAt)
        tapRecognizer.addTarget(self, action: #selector(showProfile))
        tapRecognizer.userID = message.userID
        nameLabel.gestureRecognizers = []
        nameLabel.gestureRecognizers!.append(tapRecognizer)
    }
}
