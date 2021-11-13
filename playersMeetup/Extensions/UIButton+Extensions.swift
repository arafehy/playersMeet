//
//  UIButtonExtensions.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import UIKit

extension UIButton {
    func rounded() {
        
        // set rounded and white border
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
    }
}
