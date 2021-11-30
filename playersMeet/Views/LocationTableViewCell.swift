//
//  LocationTableViewCell.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var isHereIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(with location: Location) {
        locationLabel.text = location.name
        locationImageView.af.setImage(withURL: location.imageUrl, cacheKey: location.id)
        distanceLabel.text = Formatter.getReadableString(measurement: location.distance)
        isHereIndicator.isHidden = location.id != CurrentSession.locationID
    }
}
