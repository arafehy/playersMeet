//
//  UIButtonExtensions.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit

extension UIButton {
    func rounded() {
        
        // set rounded and white border
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
    }
}
