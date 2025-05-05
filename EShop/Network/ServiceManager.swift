//
//  ServiceManager.swift
//  EShop
//
//  Created by ali cihan on 25.04.2025.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(completion: @escaping (Result<ProductResponse, NetworkError>) -> ())
}

final class ProductService: ProductServiceProtocol {
    private let network: NetworkProtocol
    
    init(network: NetworkProtocol = NetworkManager.shared) {
        self.network = network
    }
    
    func fetchProducts(completion: @escaping (Result<ProductResponse, NetworkError>) -> ()) {
        network.request(Router.allproducts, decodeTo: ProductResponse.self, completion: completion)
    }
}

protocol CartServiceProtocol {
    func fetchProductsInCart(username: String, completion: @escaping (Result<CartProductResponse, NetworkError>) -> ())
    func addProductToCart(cartProduct: CartProduct, completion: @escaping () -> ())
    func discardFromCart(cartId: Int, username: String, completion: @escaping () -> ())
}

final class CartService: CartServiceProtocol {
 
    
    private let network: NetworkProtocol
    
    init(network: NetworkProtocol = NetworkManager.shared) {
        self.network = network
    }
    
    func fetchProductsInCart(username: String, completion: @escaping (Result<CartProductResponse, NetworkError>) -> ()) {
        network.request(Router.allProductsInCart(username: username), decodeTo: CartProductResponse.self, completion: completion)
    }
    
    func addProductToCart(cartProduct: CartProduct, completion: @escaping () -> ()) {
        network.request(Router.addToCart(cartProduct: cartProduct), completion: completion)
    }
    
    func discardFromCart(cartId: Int, username: String, completion: @escaping () -> ()) {
        network.request(Router.discardProductFromCart(cartId: cartId, username: username), completion: completion)
    }
}

