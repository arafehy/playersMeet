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
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    var delegate: MessageCellDelegate?
    var message: ChatMessage? {
        didSet { configureCell() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell() {
        guard let message = message else { return }
        setNameAndTextColor(message)
        messageLabel.text = message.text
        createdAtLabel.text = Formatter.getReadableDate(timeInterval: message.createdAt)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageCell.tappedNameLabel(sender:)))
        nameLabel.gestureRecognizers = []
        nameLabel.gestureRecognizers!.append(tapRecognizer)
    }
    
    func setNameAndTextColor(_ message: ChatMessage) {
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
    }
    
    @objc func tappedNameLabel(sender: UITapGestureRecognizer) {
        guard let userID = message?.userID else { return }
        delegate?.didTapNameLabel(userID: userID)
    }
}

protocol MessageCellDelegate {
    func didTapNameLabel(userID: String)
}
