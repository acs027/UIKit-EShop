//
//  ReviewService.swift
//  EShop
//
//  Created by ali cihan on 5.05.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

final class ReviewService {
    private let db = Firestore.firestore()
    
    func writeReview(for product: Product, rating: Int, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        let reviewData: [String: Any] = [
            "rating": rating,
            "text": text,
            "userId": userId
        ]

        reviewsCollection(for: product).document(userId).setData(reviewData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchReviews(for product: Product, completion: @escaping (Result<[Review], Error>) -> Void) {
        reviewsCollection(for: product).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                let reviews = try snapshot?.documents.compactMap {
                    try $0.data(as: Review.self)
                } ?? []
                completion(.success(reviews))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func reviewsCollection(for product: Product) -> CollectionReference {
        db.collection("Reviews")
            .document(product.name)
            .collection("UserReviews")
    }
}
