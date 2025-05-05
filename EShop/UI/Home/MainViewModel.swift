//
//  MainViewModel.swift
//  EShop
//
//  Created by ali cihan on 25.04.2025.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class MainViewModel {
    @Published var reviews: [String:[Review]] = [:]
    private let coordinator: AppCoordinator
    private var service: ProductServiceProtocol
    private var cartService: CartServiceProtocol
    private let reviewService: ReviewService
    private(set) var products: [Product] = []
    var onProductsFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    private(set) var categorizedProducts: [Category: [Product]] = [:]
    
    init(coordinator: AppCoordinator, service: ProductServiceProtocol = ProductService(), cartService: CartServiceProtocol = CartService(), reviewService: ReviewService = ReviewService()) {
        self.coordinator = coordinator
        self.service = service
        self.cartService = cartService
        self.reviewService = reviewService
    }

    func fetchProducts() {
        service.fetchProducts { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let productsResponse):
                self.products = productsResponse.products
                self.filterProducts()
                self.onProductsFetched?()
                self.fetchReviews()
            case .failure:
                self.onError?("Ürünler yüklenemedi")
            }
        }
    }

    private func filterProducts() {
        let filtered = products
        var result: [Category: [Product]] = [:]
        for category in Category.allCases {
            let items = filtered.filter { $0.category == category.rawValue }
            result[category] = Array(items.prefix(2)) // Only first 2 items
        }
        categorizedProducts = result
    }

    func filteredProducts(for category: Category) -> [Product] {
        return categorizedProducts[category] ?? []
    }

    func didSelectProduct(_ product: Product) {
        coordinator.showProductDetail(product: product)
    }

    func didTapCart() {
        coordinator.showCart()
    }
    
    private func allProducts(for category: Category) -> [Product] {
        return products.filter { $0.category == category.rawValue }
    }
    
    func didTapSeeAll(for category: Category) {
        let categoryProducts = allProducts(for: category)
        coordinator.showCategoryProducts(category: category, products: categoryProducts)
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
    
    func averageRatingStars(productName: String) -> String {
        guard let productReviews = self.reviews[productName] else { return "" }
        let avg = productReviews.map(\.rating).reduce(0, +) / max(productReviews.count, 1)
        return String(repeating: "★", count: avg) + String(repeating: "☆", count: 5 - avg) + "(\(productReviews.count))"
    }
    
    func didTapSearch() {
        coordinator.showSearchedProducts(products: products)
    }
}
