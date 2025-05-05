//
//  CartViewModel.swift
//  EShop
//
//  Created by ali cihan on 27.04.2025.
//

import Foundation
import Combine
import FirebaseAuth

class CartViewModel {
    private let coordinator: AppCoordinator
    @Published var cartProducts = [CartProduct]()
    @Published private(set) var isLoading: Bool = false
    private let service: CartService
    var uniqueProducts = [String:Int]()
    
    init(coordinator: AppCoordinator, service: CartService = CartService()) {
        self.coordinator = coordinator
        self.service = service
    }
    
    func fetchProductsInCart() {
        isLoading = true
        let username = Auth.auth().currentUser?.uid ?? "acs"
        debugPrint("fetch products for \(username)")
        service.fetchProductsInCart(username: username) { [weak self] result in
            switch result {
            case .success(let response):
                self?.cartProducts = response.productsInCart
                self?.setUniqueProducts()
            case .failure(let failure):
                switch failure {
                case .decodingFailed:
                    self?.cartProducts = []
                    self?.setUniqueProducts()
                    debugPrint("empty response")
                default:
                    debugPrint("failure")
                }
            }
        }
        isLoading = false
    }
    
    func removeProductInCart(cartId: Int) {
        let username = Auth.auth().currentUser?.uid ?? "acs"
        debugPrint("remove Product for \(username)")
        service.discardFromCart(cartId: cartId, username: username) {
            
        }
    }
    
    func addProductToCart(cartProduct: CartProduct) {
        service.addProductToCart(cartProduct: cartProduct) {
            self.fetchProductsInCart()
        }
    }
    
    func backButtonTapped() {
        coordinator.backToSearch()
    }
    
    func setUniqueProducts() {
        var uniqueMap = [String : Int]()
        cartProducts.forEach( {
            if let count = uniqueMap[$0.name] {
                uniqueMap[$0.name] = $0.count + count
            } else {
                uniqueMap[$0.name] = $0.count
            }
        })
        print(uniqueMap)
        uniqueProducts = uniqueMap
        let total = cartProducts.reduce(0) { result, product in
            result + product.count
        }
        coordinator.setBadgeValue(quantity: total)
    }
    
    func updateProductQuantity(productName: String, quantity: Int) {
        let products = cartProducts.filter {
            $0.name == productName
        }
        products.forEach { product in
            removeProductInCart(cartId: product.cartId)
        }
        
        if quantity > 0 {
            var cartProduct = products.first
            cartProduct?.count = quantity
            addProductToCart(cartProduct: cartProduct!)
        } else {
            cartProducts.removeAll(where: {$0.name == productName})
        }
        setUniqueProducts()
    }
    
    func removeAll() {
        uniqueProducts.forEach { key, value in
            updateProductQuantity(productName: key, quantity: 0)
        }
    }
}
