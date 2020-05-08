//
//  MessageCell.swift
//  playersMeetup
//
//  Created by Haitao Huang on 5/4/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
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
    
}
