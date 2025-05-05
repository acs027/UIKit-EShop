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
    private let reviewService: ReviewService

    let product: Product
    @Published var quantity = 1
    @Published var reviews: [Review] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    var totalPriceText: String {
        "₺\((product.price * quantity).formatPrice())"
    }
    
    // MARK: - Computed Properties
    var productImageURL: URL? {
        URL(string: "http://kasimadalan.pe.hu/urunler/resimler/\(product.image)")
    }

    var isUserLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Initializer
    init(product: Product, coordinator: AppCoordinator, service: CartService = CartService(), reviewService: ReviewService = ReviewService()) {
        self.product = product
        self.coordinator = coordinator
        self.service = service
        self.reviewService = reviewService
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
        reviewService.writeReview(for: product, rating: rating, text: text) { [weak self] result in
            switch result {
            case .success(let success):
                self?.fetchReviews()
            case .failure(let failure):
                debugPrint(failure.localizedDescription)
            }
        }
    }

    func fetchReviews() {
        reviewService.fetchReviews(for: product) { [weak self] result in
            switch result {
            case .success(let review):
                self?.reviews = review
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }

    func averageRatingStars() -> String {
        let avg = reviews.map(\.rating).reduce(0, +) / max(reviews.count, 1)
        return String(repeating: "★", count: avg) + String(repeating: "☆", count: 5 - avg)
    }
}
