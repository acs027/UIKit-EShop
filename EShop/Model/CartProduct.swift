//
//  CartProduct.swift
//  EShop
//
//  Created by ali cihan on 25.04.2025.
//

import Foundation


struct CartProductResponse: Codable {
    let productsInCart: [CartProduct]
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case productsInCart = "urunler_sepeti"
        case success = "success"
    }
}

struct CartProduct: Codable {
    let cartId: Int
    let name: String
    let image: String
    let category: String
    let price: Int
    let brand: String
    var count: Int
    let user: String
    
    enum CodingKeys: String, CodingKey {
        case cartId = "sepetId"
        case name = "ad"
        case image = "resim"
        case category = "kategori"
        case price = "fiyat"
        case brand = "marka"
        case count = "siparisAdeti"
        case user = "kullaniciAdi"
    }
}
