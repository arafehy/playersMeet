//
//  UIViewControllerExtensions.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit

extension UIViewController {
    func showErrorAlert(with error: Error?) {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension EditProfileViewController {
    func showCancelProfileUpdateAlert() {
        let alert = UIAlertController(title: "Are you sure you want to cancel?", message: "There are unsaved changes that will be deleted.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: { _ in
            self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Continue Updating Profile", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension DetailsViewController {
    func showSwitchTeamAlert() {
        let alert = UIAlertController(title: "Are you sure you want to join?", message: "You can only join one team at a time. This will remove you from another team.", preferredStyle: .alert) // show what other team - later
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: self.switchLocation))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
