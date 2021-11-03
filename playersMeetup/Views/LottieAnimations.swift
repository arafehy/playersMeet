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

protocol Animations {
    func configureLoopingAnimation(animationName: LottieAnimations.AnimationNames, animationView: AnimationView, lottieView: UIView)
}

extension Animations {
    func configureLoopingAnimation(animationName: LottieAnimations.AnimationNames, animationView: AnimationView, lottieView: UIView) {
        animationView.animation = Animation.named(animationName.rawValue)
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
