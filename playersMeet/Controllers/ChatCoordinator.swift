//
//  ChatCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/7/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ChatFlow {
    func coordinateToProfile(profileID: String)
    func dismissChat()
}

struct ChatCoordinator: Coordinator {
    let navigationController: UINavigationController
    let user: User
    let teamID: String
    
    init(navigationController: UINavigationController, user: User, teamID: String) {
        self.navigationController = navigationController
        self.user = user
        self.teamID = teamID
    }
    
    func start() {
        let chatVC = TeamChatViewController.instantiate(user: user, teamID: teamID, coordinator: self)
        navigationController.show(chatVC, sender: nil)
    }
}

extension ChatCoordinator: ChatFlow {
    func coordinateToProfile(profileID: String) {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, user: user, profileID: profileID)
        coordinate(to: profileCoordinator)
    }
    
    func dismissChat() {
        navigationController.dismiss(animated: true)
    }
}
