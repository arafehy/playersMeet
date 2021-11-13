//
//  CGFloat+Extensions.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 11/13/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import UIKit

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
