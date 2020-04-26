//
//  LocationCell.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/25/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
