//
//  Product.swift
//  EShop
//
//  Created by ali cihan on 25.04.2025.
//

import Foundation

struct ProductResponse: Codable {
    let products: [Product]
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case products = "urunler"
        case success = "success"
    }
}

struct Product: Codable {
    let id: Int
    let name: String
    let image: String
    let category: String
    let price: Int
    let brand: String

 
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "ad"
        case image = "resim"
        case category = "kategori"
        case price = "fiyat"
        case brand = "marka"
    }
}
