//
//  Animation.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/1/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import Lottie
import UIKit

protocol Animations {
    func configureLoopingAnimation(animation: LottieAnimations.AnimationNames, animationView: LottieAnimationView, lottieView: UIView)
}

extension Animations {
    func configureLoopingAnimation(animation: LottieAnimations.AnimationNames, animationView: LottieAnimationView, lottieView: UIView) {
        animationView.animation = LottieAnimation.named(animation.rawValue)
        animationView.frame.size = lottieView.frame.size
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        lottieView.addSubview(animationView)
    }
}

struct LottieAnimations {
    enum AnimationNames: String {
        case loading = "18709-loading"
        case bouncingBall = "4414-bouncy-basketball"
    }
}

extension SignUpViewController: Animations {}
extension ProfileViewController: Animations {}
