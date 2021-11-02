//
//  Animation.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 11/1/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import Foundation
import Lottie
import UIKit

struct LottieAnimations {
    static func configureLoopingAnimation(animationName: String, animationView: AnimationView, lottieView: UIView) {
        animationView.animation = Animation.named(animationName)
        animationView.frame.size = lottieView.frame.size
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        lottieView.addSubview(animationView)
    }
}
