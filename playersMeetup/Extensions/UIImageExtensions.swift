//
//  UIImageExtensions.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 10/30/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import UIKit

extension UIImageView {
    func configureProfilePicture() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor.systemGray.cgColor
    }
}
