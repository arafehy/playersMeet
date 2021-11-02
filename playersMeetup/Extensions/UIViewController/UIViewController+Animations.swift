//
//  UIViewController+Animations.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 11/1/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import Foundation
import Lottie

extension SignUpViewController {
    func configureBackgroundLoadingAnimation() {
        LottieAnimations.configureLoopingAnimation(animationName: "18709-loading", animationView: animationView, lottieView: lottieView)
    }
}

extension ProfileViewController {
    func configureBouncingBallAnimation() {
        LottieAnimations.configureLoopingAnimation(animationName: "4414-bouncy-basketball", animationView: animationView, lottieView: lottieView)
    }
}
