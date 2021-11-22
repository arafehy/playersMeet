//
//  UIImageExtensions.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 10/30/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit

extension UIImageView {
    func configureProfilePicture() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor.systemGray.cgColor
    }
}
