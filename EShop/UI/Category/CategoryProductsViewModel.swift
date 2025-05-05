//
//  CategoryProductsViewModel.swift
//  EShop
//
//  Created by ali cihan on 30.04.2025.
//

import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

class CategoryProductsViewModel {
    @Published var reviews: [String:[Review]] = [:]
    private let coordinator: AppCoordinator
    private var cartService: CartServiceProtocol
    private let reviewService: ReviewService
    let category: Category
    let products: [Product]
    
    init(category: Category, products: [Product], coordinator: AppCoordinator, cartService: CartServiceProtocol = CartService(), reviewService: ReviewService = ReviewService()) {
        self.category = category
        self.products = products
        self.coordinator = coordinator
        self.cartService = cartService
        self.reviewService = reviewService
    }
    
    func didSelectProduct(_ product: Product) {
        coordinator.showProductDetail(product: product)
    }
    
    func didTapCart() {
        coordinator.showCart()
    }
    
    func fetchReviews() {
        products.forEach{ product in
            reviewService.fetchReviews(for: product) { [weak self] result in
                switch result {
                case .success(let review):
                    self?.reviews[product.name] = review
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    
    func averageRatingStars(productName: String) -> String {
        guard let productReviews = self.reviews[productName] else { return "" }
        let avg = productReviews.map(\.rating).reduce(0, +) / max(productReviews.count, 1)
        return String(repeating: "★", count: avg) + String(repeating: "☆", count: 5 - avg) + "(\(productReviews.count))"
    }
    
    func addToCart(productName: String) {
        guard let product = products.first(where: {$0.name == productName}) else { return }
        let cartProduct = CartProduct(
            cartId: 1,
            name: product.name,
            image: product.image,
            category: product.category,
            price: product.price,
            brand: product.brand,
            count: 1,
            user: Auth.auth().currentUser?.uid ?? "acs"
        )
        cartService.addProductToCart(cartProduct: cartProduct) {
            self.coordinator.addToBadge(quantity: 1)
        }
    }
}
