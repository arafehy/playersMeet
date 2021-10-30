//
//  UIViewControllerExtensions.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import UIKit

extension UIViewController {
    func showErrorAlert(with error: Error?) {
        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
