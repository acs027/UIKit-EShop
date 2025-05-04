//
//  Int+Extension.swift
//  EShop
//
//  Created by ali cihan on 4.05.2025.
//

import Foundation

extension Int {
    func formatPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
