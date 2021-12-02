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
        var nameLabelText = message.username
        switch message.origin {
        case .currentUser:
            nameLabelText += " (Me)"
            self.nameLabel.textColor = UIColor.orange
        case .teammate:
            let hexColor: String = message.color != "#000000" ? message.color : "#808080"
            self.nameLabel.textColor = UIColor(hexString: hexColor)
        }
        
        nameLabel.text = nameLabelText
        msgLabel.text = message.text
        createdAtLabel.text = Formatter.getReadableDate(timeInterval: message.createdAt)
        tapRecognizer.addTarget(self, action: #selector(showProfile))
        tapRecognizer.userID = message.userID
        nameLabel.gestureRecognizers = []
        nameLabel.gestureRecognizers!.append(tapRecognizer)
    }
}
