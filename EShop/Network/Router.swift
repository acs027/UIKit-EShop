//
//  Router.swift
//  EShop
//
//  Created by ali cihan on 25.04.2025.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    case allproducts
    case allProductsInCart(username: String?)
    case addToCart(cartProduct: CartProduct?)
    case discardProductFromCart(cartId: Int?, username: String?)
    
    
    var baseURL: URL? {
        return URL(string: "http://kasimadalan.pe.hu/urunler")
    }
    
    var path: String {
        switch self {
        case .allproducts:
            return "tumUrunleriGetir.php"
        case .allProductsInCart:
            return "sepettekiUrunleriGetir.php"
        case .addToCart:
            return "sepeteUrunEkle.php"
        case .discardProductFromCart:
            return "sepettenUrunSil.php"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .allproducts:
            return .get
        default:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        var params: Parameters = [:]
        switch self {
        case .addToCart(cartProduct: let cartProduct):
            params["ad"] = cartProduct?.name
            params["resim"] = cartProduct?.image
            params["kategori"] = cartProduct?.category
            params["fiyat"] = cartProduct?.price
            params["marka"] = cartProduct?.brand
            params["siparisAdeti"] = cartProduct?.count
            params["kullaniciAdi"] = cartProduct?.user
        
        case .discardProductFromCart(cartId: let cartId, username: let username):
            params["sepetId"] = cartId
            params["kullaniciAdi"] = username
            
        case .allProductsInCart(username: let username):
            params["kullaniciAdi"] = username
        default:
            return params
        }
        return params
    }
    
    var encoding: ParameterEncoding {
        switch method {
        default:
            return URLEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let baseURL else { throw URLError(.badURL)}
        var urlRequest = URLRequest(url: baseURL.appending(path: path))
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 10
        urlRequest.allHTTPHeaderFields = [
            "accept": "application/json",
//            "Authorization": "Bearer \(Bundle.main.object(forInfoDictionaryKey: "API_KEY")!)"
            
        ]
        
        do {
            let request = try encoding.encode(urlRequest, with: parameters)
            debugPrint("*** Request URL: ", request.url ?? "")
            return request
        }
        catch {
            debugPrint("*** Error \(error.localizedDescription)")
            throw error
        }
    }
}
