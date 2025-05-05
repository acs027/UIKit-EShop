//
//  UIButton+Extension.swift
//  EShop
//
//  Created by ali cihan on 5.05.2025.
//

import Foundation
import UIKit

extension UIButton {
    func applyFilledStyle(title: String, backgroundColor: UIColor) {
        setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        tintColor = .white
        layer.cornerRadius = 12
        titleLabel?.font = .boldSystemFont(ofSize: 18)
    }
}
