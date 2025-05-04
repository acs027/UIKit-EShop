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
    private let coordinator: AppCoordinator
    let category: Category
    let products: [Product]
    private let db = Firestore.firestore()
    @Published var reviews: [String:[Review]] = [:]
    private var cartService: CartServiceProtocol
    
    init(category: Category, products: [Product], coordinator: AppCoordinator, cartService: CartServiceProtocol = CartService()) {
        self.category = category
        self.products = products
        self.coordinator = coordinator
        self.cartService = cartService
    }
    
    func didSelectProduct(_ product: Product) {
        coordinator.showProductDetail(product: product)
    }
    
    func didTapCart() {
        coordinator.showCart()
    }
    
    func fetchReviews() {
        products.forEach{ product in
            reviewsCollection(productName: product.name).getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching reviews: \(error.localizedDescription)")
                    return
                }

                do {
                    self.reviews[product.name] = try snapshot?.documents.compactMap {
                        try $0.data(as: Review.self)
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }
    }
    
    private func reviewsCollection(productName: String) -> CollectionReference {
        db.collection("Reviews")
            .document(productName)
            .collection("UserReviews")
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
