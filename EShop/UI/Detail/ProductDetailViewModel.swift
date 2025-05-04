//
//  ProductDetailViewModel.swift
//  EShop
//
//  Created by ali cihan on 27.04.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class ProductDetailViewModel {
    // MARK: - Dependencies
    private let coordinator: AppCoordinator
    private let service: CartService
    private let db = Firestore.firestore()

    // MARK: - Properties
    let product: Product
    @Published var quantity = 1
    private(set) var reviews: [Review] = []
    var reviewsPublisher = PassthroughSubject<[Review], Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var productImageURL: URL? {
        URL(string: "http://kasimadalan.pe.hu/urunler/resimler/\(product.image)")
    }

    var isUserLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Initializer
    init(product: Product, coordinator: AppCoordinator, service: CartService = CartService()) {
        self.product = product
        self.coordinator = coordinator
        self.service = service
    }

    // MARK: - Public Methods
    func addToCart() {
        let cartProduct = CartProduct(
            cartId: 1,
            name: product.name,
            image: product.image,
            category: product.category,
            price: product.price,
            brand: product.brand,
            count: quantity,
            user: Auth.auth().currentUser?.uid ?? "acs"
        )
        service.addProductToCart(cartProduct: cartProduct) {
            self.coordinator.addToBadge(quantity: self.quantity)
        }
    }

    func didTapCart() {
        coordinator.showCart()
    }

    func writeReview(rating: Int, text: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let reviewData: [String: Any] = [
            "rating": rating,
            "text": text,
            "userId": userId
        ]

        reviewsCollection().document(userId).setData(reviewData) { [weak self] error in
            if let error = error {
                print("Error writing review: \(error.localizedDescription)")
            } else {
                print("Review successfully written!")
                self?.fetchReviews()
            }
        }
    }

    func fetchReviews() {
        reviewsCollection().getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching reviews: \(error.localizedDescription)")
                return
            }

            do {
                self.reviews = try snapshot?.documents.compactMap {
                    try $0.data(as: Review.self)
                } ?? []
                self.reviewsPublisher.send(self.reviews)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }

    func averageRatingStars() -> String {
        let avg = reviews.map(\.rating).reduce(0, +) / max(reviews.count, 1)
        return String(repeating: "★", count: avg) + String(repeating: "☆", count: 5 - avg)
    }

    func totalPrice() -> String {
        "\((quantity * product.price).formatPrice())"
    }

    // MARK: - Private Helpers
    private func reviewsCollection() -> CollectionReference {
        db.collection("Reviews")
            .document(product.name)
            .collection("UserReviews")
    }
}
