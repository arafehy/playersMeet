//
//  LocationCell.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var isHereIndicator: UIImageView!
    
    var location: Location? {
        didSet { configure() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure() {
        guard let location = location else { return }
        locationLabel.text = location.name
        locationImageView.af.setImage(withURL: location.imageUrl, cacheKey: location.id)
        distanceLabel.text = Formatter.getReadableMeasurement(location.distance)
        isHereIndicator.isHidden = location.id != CurrentSession.locationID
    }
}
