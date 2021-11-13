//
//  UITextFieldExtensions.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import UIKit

extension UITextField {
    func rounded() {
        self.layer.cornerRadius = 25
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
    }
    
    func configure() {
        self.layer.zPosition = 1
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.zPosition = 1
    }
}

extension UITextView {
    func configure() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.separator.cgColor
    }
    
    func reset(with placeholderText: String) {
        self.text = placeholderText
        self.textColor = .placeholderText
        self.selectedTextRange = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument)
    }
}
