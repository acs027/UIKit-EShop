//
//  Review.swift
//  EShop
//
//  Created by ali cihan on 3.05.2025.
//

import Foundation
import FirebaseFirestore

struct Review: Codable, Identifiable {
    @DocumentID var id: String? // Firestore document ID
    let rating: Int
    let text: String
    let userId: String
}
